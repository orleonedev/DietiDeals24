using System.Data.Common;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.RestApi.Workers;

public interface IAuctionWorker
{
    public Task<Auction> GetAuctionById(Guid id);
    public Task<PaginatedResult<HomePageAuctionDTO>> GetHomePageAuctions(int pageNumber, int pageSize);
}