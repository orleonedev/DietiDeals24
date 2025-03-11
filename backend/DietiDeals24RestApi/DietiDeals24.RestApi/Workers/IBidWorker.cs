using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.RestApi.Workers;

public interface IBidWorker
{
    public Task<CreateBidDTO> CreateBidAsync(CreateBidDTO bid);
}