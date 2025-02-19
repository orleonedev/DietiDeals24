using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IAuctionService
{
    public Task<Auction> GetAuctionByIdAsync(Guid id);
    public Task<PaginatedResult<HomePageAuctionDTO>> GetAllAuctionsAsync(int pageNumber, int pageSize, string? predicate = null, params object[] parameters);
    public Task<int> GetOffersForAuctionAsync(Guid auctionId);
}