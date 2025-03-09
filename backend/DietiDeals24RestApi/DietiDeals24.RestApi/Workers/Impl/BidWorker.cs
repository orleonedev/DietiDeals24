using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;
using Exception = System.Exception;

namespace DietiDeals24.RestApi.Workers.Impl;

public class BidWorker: IBidWorker
{
    private readonly ILogger<BidWorker> _logger;
    private readonly IBidService _bidService;
    private readonly IAuctionService _auctionService;

    public BidWorker(ILogger<BidWorker> logger, IBidService bidService, IAuctionService auctionService)
    {
        _logger = logger;
        _bidService = bidService;
        _auctionService = auctionService;
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

            if (auction.AuctionType == AuctionType.Descending)
            {
                auction.AuctionState = AuctionState.Closed;
                auction.EndingDate = now;
                //notificare chi ha vinto l'asta e il venditore
            }
            else
            {
                auction.CurrentPrice = bid.Price;
                auction.EndingDate = actualDate.AddHours(auction.Timer);
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