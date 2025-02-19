using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;
using System.Timers;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using AuctionType = DietiDeals24.DataAccessLayer.Models.AuctionType;

namespace DietiDeals24.DataAccessLayer.Services;

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
                AuctionImages = auction.AuctionImages.Select( image => new AuctionImage
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

    public async Task<PaginatedResult<HomePageAuctionDTO>> GetAllAuctionsAsync(int pageNumber, int pageSize, string? predicate = null, params object[] parameters)
    {
        try
        {
            var auctions = _unitOfWork.AuctionRepository.Get(predicate, parameters);
            var totalRecords = await auctions.CountAsync();
            
            var paginatedAuctions = await auctions
                .OrderBy(auction => auction.EndingDate) 
                .Skip((pageNumber - 1) * pageSize) // Permits to skip pages
                .Take(pageSize)
                .Select(auction => new HomePageAuctionDTO
                {
                    Id = auction.Id,
                    Title = auction.Title,
                    Type = (AuctionType)auction.AuctionType,
                    CurrentPrice = auction.CurrentPrice,
                    Threshold = auction.Threshold,
                    ThresholdTimer = auction.Timer
                })
                .ToListAsync();

            return new PaginatedResult<HomePageAuctionDTO>(paginatedAuctions, totalRecords);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting home page auctions failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting home page auctions failed.", ex);
        }
    }

    public Task<int> GetOffersForAuctionAsync(Guid auctionId)
    {
        try
        {
            return _unitOfWork.BidRepository.Get(bid => bid.AuctionId == auctionId).CountAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting home page auctions failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting home page auctions failed.", ex);
        }
    }
}