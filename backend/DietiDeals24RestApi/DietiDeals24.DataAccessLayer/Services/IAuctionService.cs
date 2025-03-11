using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IAuctionService
{
    public Task<List<Auction>> GetAllAuctionsAsync(string? predicate = null, params object[] parameters);
    public Task<List<Auction>> GetPaginatedAuctionsAsync(AuctionFiltersDTO filters, string? predicate = null, params object[] parameters);
    public Task<Auction> GetAuctionByIdAsync(Guid id);
    public Task<Auction> CreateAuctionAsync(CreateAuctionDTO auction, Vendor vendor);
    public Task<Auction> UpdateAuctionAsync(Auction auction);
}