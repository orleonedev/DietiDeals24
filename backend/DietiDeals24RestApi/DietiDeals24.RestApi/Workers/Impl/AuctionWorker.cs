using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;
using AuctionType = DietiDeals24.DataAccessLayer.Models.AuctionType;

namespace DietiDeals24.RestApi.Workers;

public class AuctionWorker: IAuctionWorker
{
    private readonly ILogger<AuctionWorker> _logger;
    private readonly IAuctionService _auctionService;

    public AuctionWorker(
        ILogger<AuctionWorker> logger, 
        IAuctionService auctionService)
    {
        _logger = logger;
        _auctionService = auctionService;
    }

    public async Task<Auction> GetAuctionById(Guid id)
    {
        _logger.LogInformation("[WORKER] Getting auction with id: {id}", id);
        var auction = await _auctionService.GetAuctionByIdAsync(id);
        return auction;
    }

    public async Task<PaginatedResult<HomePageAuctionDTO>> GetHomePageAuctions(int pageNumber, int pageSize)
    {
        _logger.LogInformation("[WORKER] Getting home page auctions");

        try
        {
            var auctions = await _auctionService.GetAllAuctionsAsync(pageNumber, pageSize);

            foreach (HomePageAuctionDTO auction in auctions.Results)
            {
                if(auction.Type == AuctionType.EnglishLike){
                    var offers = _auctionService.GetOffersForAuctionAsync(auction.Id).Result;
                    auction.Offers = offers;
                }
            }

            return auctions;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Getting home page auctions failed: {ex.Message}");
            throw new Exception("[WORKER] Getting home page auctions failed.", ex);
        }
    }
}