using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;

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
        //var buyer = await _authenticationService.GetUserAsync(bidDto.BuyerId);

        if (auction == null)
        {
            throw new ArgumentNullException(nameof(bidDto.AuctionId), $"AuctionId {bidDto.AuctionId} not found.");
        }

        if (bidDto.Price <= auction.CurrentPrice)
        {
            throw new InvalidOperationException("Price must be greater than CurrentPrice.");
        }

        if (auction.AuctionState != AuctionState.Open)
        {
            throw new InvalidOperationException("Auction state must be Open.");
        }

        try
        {
            var bid = await _bidService.CreateBidAsync(bidDto, auction);

            if (bid != null)
            {
                //auction.Bids = auction.Bids.ToList();
                auction.Bids.ToList().Add(bid);
            }

            return new CreateBidDTO
            {
                AuctionId = bid.AuctionId,
                BuyerId = bid.BuyerId,
                Price = bid.Price,
                BidDate = bid.OfferDate
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Creating new bid failed for Auction {bidDto.AuctionId}: {ex.Message}");
            throw new Exception($"[WORKER] Creating new bid failed for Auction {bidDto.AuctionId}: {ex.Message}.", ex);
        }
    }
}