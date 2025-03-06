using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IBidService
{
    public Task<Dictionary<Guid, int>> GetBidsCountForAuctionAsync(List<Guid> auctionIds);
    public Task<int> GetBidsCountForAuctionAsync(Guid auctionId);
    public Task<Bid> CreateBidAsync(CreateBidDTO bidDto);
}