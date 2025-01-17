using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Services;

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
}