using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IAuctionService
{
    public Task<Auction> GetAuctionByIdAsync(Guid id);
    public Task<IQueryable<Auction>> GetAllAuctionsAsync(string? predicate = null, params object[] parameters);
    public Task<PaginatedResult<HomePageAuctionDTO>> GetPaginatedAuctionsAsync(int page, int pageSize, AuctionFilters filters, string? predicate = null, params object[] parameters);
    public Task<DetailedAuctionDTO> CreateAuctionAsync(CreateAuctionDTO auction);
}