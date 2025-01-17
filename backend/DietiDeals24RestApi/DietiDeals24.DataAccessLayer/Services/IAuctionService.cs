using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IAuctionService
{
    public Task<Auction> GetAuctionByIdAsync(Guid id);
    public Task<List<Auction>> GetAllAuctionsAsync();
    public Task<List<Auction>> GetAllAuctionsAsync(int skip, int limit);
}