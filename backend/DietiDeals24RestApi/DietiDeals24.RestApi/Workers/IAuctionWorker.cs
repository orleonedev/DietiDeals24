using System.Data.Common;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.RestApi.Workers;

public interface IAuctionWorker
{
    public Task<Auction> GetAuctionById(Guid id);
}