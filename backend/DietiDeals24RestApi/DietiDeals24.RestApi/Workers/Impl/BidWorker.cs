using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;
using Exception = System.Exception;

namespace DietiDeals24.RestApi.Workers.Impl;

public class BidWorker: IBidWorker
{
    private readonly ILogger<BidWorker> _logger;
    private readonly IBidService _bidService;
    private readonly IVendorService _vendorService;
    private readonly IImageService _imageService;
    private readonly IAuctionService _auctionService;
    private readonly INotificationWorker _notificationWorker;
    private readonly EventBridgeSchedulerService _eventBridgeSchedulerService;

    public BidWorker(ILogger<BidWorker> logger, 
        IBidService bidService,
        IAuctionService auctionService, 
        EventBridgeSchedulerService eventBridgeSchedulerService, 
        INotificationWorker notificationWorker, 
        IImageService imageService, 
        IVendorService vendorService)
    {
        _logger = logger;
        _bidService = bidService;
        _auctionService = auctionService;
        _eventBridgeSchedulerService = eventBridgeSchedulerService;
        _notificationWorker = notificationWorker;
        _imageService = imageService;
        _vendorService = vendorService;
    }

    public async Task<CreateBidDTO> CreateBidAsync(CreateBidDTO bidDto)
    {
        _logger.LogInformation($"[WORKER] Creating new bid for Auction: {bidDto.AuctionId}");

        var auction = await _auctionService.GetAuctionByIdAsync(bidDto.AuctionId);
        ValidateBidInput(auction, bidDto.Price);

        try
        {
            var bid = await _bidService.CreateBidAsync(bidDto);

            var newBid = new CreateBidDTO
            {
                AuctionId = bid.AuctionId,
                BuyerId = bid.BuyerId,
                Price = bid.Price
            };
            
            DateTime now = DateTime.Now;
            DateTime actualDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);

            var vendor = await _vendorService.GetVendorByIdAsync(auction.VendorId);
            var imageList = await _imageService.GetImagesUrlsForAuctionAsync(auction.Id);
            var mainImageUrl = imageList.FirstOrDefault();
            
            var notification = new NotificationDTO
            {
                MainImageUrl = mainImageUrl,
                AuctionId = auction.Id,
                AuctionTitle = auction.Title
            };
            
            if (auction.AuctionType == AuctionType.Descending)
            {
                auction.AuctionState = AuctionState.Closed;
                auction.EndingDate = now;
                await _vendorService.AddSuccessfulAuctionToVendorAsync(vendor.Id);
                await _eventBridgeSchedulerService.DeleteScheduledAuctionEndEvent(auction.Id.ToString());
                
                notification.Type = NotificationType.AuctionClosed;
                notification.Message = "auction.won.message";
                notification.Message = "auction.successfully.closed.message";
                try
                {
                    await _notificationWorker.SendNotificationAsync(bidDto.BuyerId, notification);
                    await _notificationWorker.SendNotificationAsync(vendor.UserId, notification);
                }
                catch (Exception ex)
                {
                    _logger.LogError($"[WORKER] Failed to send notification. Exception occurred: {ex.Message}");
                }
            }
            else
            {
                auction.CurrentPrice = bid.Price;
                auction.EndingDate = actualDate.AddHours(auction.Timer);
                var response = await _eventBridgeSchedulerService.ScheduleAuctionEndEvent(auction.Id.ToString(), auction.EndingDate);
                notification.Type = NotificationType.AuctionBid;
                notification.Message = "new.bid.message";
                try
                {
                    await _notificationWorker.SendNotificationAsync(vendor.UserId, notification);
                }
                catch (Exception ex)
                {
                    _logger.LogError($"[WORKER] Failed to send notification. Exception occurred: {ex.Message}");
                }
            }
            
            await _auctionService.UpdateAuctionAsync(auction);
            
            return newBid;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Creating new bid failed for Auction {bidDto.AuctionId}: {ex.Message}");
            throw new Exception($"[WORKER] Creating new bid failed for Auction {bidDto.AuctionId}: {ex.Message}.", ex);
        }
    }
    
    private void ValidateBidInput(Auction auction, decimal price)
    {
        if (auction == null)
        {
            throw new ArgumentNullException(nameof(auction), $"[WORKER] Auction not found.");
        }

        if (auction.AuctionState != AuctionState.Open)
        {
            throw new InvalidOperationException("[WORKER] Auction state must be Open.");
        }
        
        if (auction.AuctionType == AuctionType.Incremental && price < auction.CurrentPrice + auction.Threshold)
        {
            throw new InvalidOperationException("[WORKER] Invalid price for incremental auction.");
        }
        
        if (auction.AuctionType == AuctionType.Descending && price < auction.CurrentPrice)
        {
            throw new InvalidOperationException("[WORKER] Invalid price for descending auction.");
        }
    }
}