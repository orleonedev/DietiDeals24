using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class AuctionService : IAuctionService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<AuctionService> _logger;

    public AuctionService(IUnitOfWork unitOfWork, ILogger<AuctionService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }
    
    public async Task<bool> AuctionExistsAsync(Guid auctionId)
    {
        try
        {
            return await _unitOfWork.AuctionRepository
                .Get(auction => auction.Id == auctionId)
                .AnyAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Checking auction with id {auctionId} failed. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Checking auction with id {auctionId} failed. Exception occurred: {ex.Message}.", ex);
        }
    }

    public async Task<List<Auction>> GetAllAuctionsAsync(string? predicate = null, params object[] parameters)
    {
        try
        {
            var auctions = _unitOfWork.AuctionRepository.Get(predicate, parameters);

            return await auctions
                .OrderBy(auction => auction.Id)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting all auctions failed. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Getting all auctions failed. Exception occurred: {ex.Message}", ex);
        }
    }

    public async Task<List<Auction>> GetPaginatedAuctionsAsync(AuctionFiltersDTO filters, 
        string? predicate = null, params object[] parameters)
    {
        _logger.LogInformation("[SERVICE] Getting paginated auctions.");
        
        try
        {
            var query = _unitOfWork.AuctionRepository
                .Get(
                    auction => (auction.AuctionState == AuctionState.Open) && 
                        (filters.SearchText == null || auction.Title.ToLower().Contains(filters.SearchText.ToLower())) &&
                        (filters.Category == null || auction.Category == filters.Category) && 
                        (filters.Type == null || auction.AuctionType == filters.Type.Value) &&
                        (filters.MinPrice == null || auction.CurrentPrice >= filters.MinPrice) &&
                        (filters.MaxPrice == null || auction.CurrentPrice <= filters.MaxPrice) &&
                        (filters.VendorId == null || auction.VendorId == filters.VendorId)
                );
            
            query = filters.Order switch
            {
                AuctionSortOrder.MostBids => query.OrderByDescending(auction => auction.Bids.Count),
                AuctionSortOrder.PriceHighToLow => query.OrderByDescending(auction => auction.CurrentPrice),
                AuctionSortOrder.PriceLowToHigh => query.OrderBy(auction => auction.CurrentPrice),
                AuctionSortOrder.NewestFirst => query.OrderByDescending(auction => auction.StartingDate),
                _ => query // Default case: No sorting
            };
            
            var paginatedAuctions = await query
                .Skip((filters.PageNumber - 1) * filters.PageSize)
                .Take(filters.PageSize)
                .ToListAsync();
            
            return paginatedAuctions;

        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting home page auctions failed. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Getting home page auctions failed. Exception occurred: {ex.Message}", ex);
        }
    }

    public async Task<Auction> GetAuctionByIdAsync(Guid auctionId)
    {
        try
        {
            return await _unitOfWork.AuctionRepository
                .Get(auction => auction.Id == auctionId)
                .FirstOrDefaultAsync() ?? throw new InvalidOperationException();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting auction with id {auctionId} failed. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Getting auction with id {auctionId} failed. Exception occurred: {ex.Message}.", ex);
        }
    }
    
    public async Task<Auction> CreateAuctionAsync(CreateAuctionDTO auction, Vendor vendor)
    {
        try
        {
            if (auction == null) throw new ArgumentNullException(nameof(auction), "[SERVICE] CreateAuctionDTO is null.");
            if (vendor == null) throw new ArgumentNullException(nameof(vendor), "[SERVICE] Vendor does not exist.");

            DateTime now = DateTime.Now;
            DateTime startingDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
            
            var newAuction = new Auction
            {
                Title = auction.Title,
                AuctionDescription = auction.Description,
                StartingPrice = auction.StartingPrice,
                CurrentPrice = auction.StartingPrice,
                AuctionType = auction.Type,
                Threshold = auction.Threshold,
                Timer = auction.ThresholdTimer,
                SecretPrice = auction.SecretPrice,
                VendorId = vendor.Id,
                AuctionState = AuctionState.Open,
                StartingDate = startingDate,
                EndingDate = startingDate.AddHours(auction.ThresholdTimer),
                Category = auction.Category
            };

            _unitOfWork.BeginTransaction();
            await _unitOfWork.AuctionRepository.Add(newAuction);
            _unitOfWork.Commit();
            await _unitOfWork.Save();
            
            return newAuction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Creating new auction failed. Exception occurred:: {ex.Message}");
            throw new Exception($"[SERVICE] Creating new auction failed. Exception occurred: {ex.Message}", ex);
        }
    }

    public async Task<Auction> UpdateAuctionAsync(Auction auction)
    {
        try
        {
            _unitOfWork.BeginTransaction();
            await _unitOfWork.AuctionRepository.Update(auction);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

            return await GetAuctionByIdAsync(auction.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Updating auction state with id: {auction.Id} failed. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Updating auction state with id: {auction.Id} failed. Exception occurred: {ex.Message}", ex);
        }
    }
}