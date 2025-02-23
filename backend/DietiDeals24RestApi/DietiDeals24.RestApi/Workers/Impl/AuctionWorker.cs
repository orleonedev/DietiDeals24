using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
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

    public async Task<List<Auction>> GetAllAuctions()
    {
        _logger.LogInformation("[WORKER] Getting all auctions");

        try
        {
            var auctions = await _auctionService.GetAllAuctionsAsync();

            return auctions.ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Getting all auctions failed: {ex.Message}");
            throw new Exception("[WORKER] Getting all auctions failed.", ex);
        }
    }

    public async Task<PaginatedResult<HomePageAuctionDTO>> GetPaginatedAuctions(int pageNumber, int pageSize, AuctionFilters filters)
    {
        _logger.LogInformation("[WORKER] Getting paginated auctions");

        try
        {
            return await _auctionService.GetPaginatedAuctionsAsync(pageNumber, pageSize, filters);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Getting paginated auctions failed: {ex.Message}");
            throw new Exception("[WORKER] Getting paginated auctions failed.", ex);
        }
    }
}