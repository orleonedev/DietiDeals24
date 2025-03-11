using System.Data.Common;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.RestApi.Workers;

public interface IAuctionWorker
{
    public Task<Auction> GetAuctionById(Guid id);
    public Task<List<Auction>> GetAllAuctions();
    public Task<DetailedAuctionDTO> GetDetailedAuctionById(Guid id);
    public Task<PaginatedResult<HomePageAuctionDTO>> GetPaginatedAuctions(AuctionFiltersDTO filters);
    public Task<CreateAuctionResponseDTO> CreateAuction(CreateAuctionDTO auction);
    public Task OnAuctionEndTimeReached(Guid auctionId);
}