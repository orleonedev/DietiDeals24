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

    public async Task<Auction> GetAuctionByIdAsync(Guid id)
    {
        _logger.LogInformation("[SERVICE] Getting auction with id: {id}", id);
        var auction = await _unitOfWork.AuctionRepository
            .Get(auction => auction.Id == id)
            .Select( auction => new Auction
            {
                Id = auction.Id,
                Title = auction.Title,
                AuctionDescription = auction.AuctionDescription,
                StartingPrice = auction.StartingPrice,
                CurrentPrice = auction.CurrentPrice,
                AuctionType = auction.AuctionType,
                Threshold = auction.Threshold,
                Timer = auction.Timer,
                SecretPrice = auction.SecretPrice,
                VendorId = auction.VendorId,
                Vendor = new Vendor
                {
                    Id = auction.Vendor.Id,
                    UserId = auction.Vendor.UserId,
                    StartingDate = auction.Vendor.StartingDate,
                    SuccessfulAuctions = auction.Vendor.SuccessfulAuctions
                },
                CategoryId = auction.CategoryId,
                Category = auction.Category,
                AuctionState = auction.AuctionState,
                StartingDate = auction.StartingDate,
                EndingDate = auction.EndingDate,
                AuctionImages = auction.AuctionImages.Select(image => new AuctionImage
                {
                    Id = image.Id,
                    AuctionId = image.AuctionId,
                    Url = image.Url,
                }).ToArray(),
                Bids = auction.Bids.Select(bid => new Bid
                {
                    Id = bid.Id,
                    Price = bid.Price,
                    AuctionId = bid.AuctionId,
                    BuyerId = bid.BuyerId,
                    OfferDate = bid.OfferDate
                }).ToArray()
            })
            .SingleOrDefaultAsync();

        if (auction == null) return null;
        
        return new Auction
        {
            Id = auction.Id,
            Title = auction.Title,
            AuctionDescription = auction.AuctionDescription,
            StartingPrice = auction.StartingPrice,
            CurrentPrice = auction.CurrentPrice,
            AuctionType = auction.AuctionType,
            Threshold = auction.Threshold,
            Timer = auction.Timer,
            SecretPrice = auction.SecretPrice,
            VendorId = auction.VendorId,
            Vendor = auction.Vendor,
            CategoryId = auction.CategoryId,
            Category = auction.Category,
            AuctionState = auction.AuctionState,
            StartingDate = auction.StartingDate,
            EndingDate = auction.EndingDate,
            AuctionImages = auction.AuctionImages,
            Bids = auction.Bids
        };
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
            _logger.LogError(ex, $"[SERVICE] Getting all auctions failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting all auctions failed.", ex);
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
                        //(filters.Category == null || auction.Category == filters.Category) && 
                        (filters.Type == null || auction.AuctionType == filters.Type.Value) &&
                        (filters.MinPrice == 0 || auction.CurrentPrice >= filters.MinPrice) &&
                        (filters.MaxPrice == 0 || auction.CurrentPrice <= filters.MaxPrice) &&
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
            _logger.LogError(ex, $"[SERVICE] Getting home page auctions failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting home page auctions failed.", ex);
        }
    }

    public async Task<Auction> GetDetailedAuctionByIdAsync(Guid auctionId)
    {
        try
        {
            return await _unitOfWork.AuctionRepository
                .Get(auction => auction.Id == auctionId)
                .FirstOrDefaultAsync() ?? throw new InvalidOperationException();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting detailed auction failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting detailed auction failed.", ex);
        }
    }
    
    public async Task<Auction> CreateAuctionAsync(CreateAuctionDTO auction, Vendor vendor)
    {
        try
        {
            if (auction == null) throw new ArgumentNullException(nameof(auction), "[SERVICE] CreateAuctionDTO is null.");
            if (vendor == null) throw new ArgumentNullException(nameof(vendor), "[SERVICE] Vendor does not exist.");

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
                StartingDate = DateTime.Now,
                EndingDate = DateTime.Now.AddHours(auction.ThresholdTimer)
                //Category = auction.Category,
            };

            _unitOfWork.BeginTransaction();
            await _unitOfWork.AuctionRepository.Add(newAuction);
            _unitOfWork.Commit();
            await _unitOfWork.Save();
            
            return newAuction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Creating new auction failed: {ex.Message}");
            throw new Exception("[SERVICE] Creating new auction failed.", ex);
        }
    }
    
}