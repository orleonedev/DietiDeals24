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

    public async Task<IQueryable<Auction>> GetAllAuctionsAsync(string? predicate = null, params object[] parameters)
    {
        try
        {
            var auctions = _unitOfWork.AuctionRepository.Get(predicate, parameters);

            return auctions
                .OrderBy(auction => auction.EndingDate);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting all auctions failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting all auctions failed.", ex);
        }
    }

    public async Task<PaginatedResult<HomePageAuctionDTO>> GetPaginatedAuctionsAsync(int pageNumber, int pageSize,
        string? predicate = null, params object[] parameters)
    {
        try
        {
            var query = _unitOfWork.AuctionRepository.Get(predicate, parameters);

            var totalRecords = await query.CountAsync();

            var paginatedAuctions = await query
                .OrderBy(a => a.Id)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var auctionIds = paginatedAuctions.Select(a => a.Id).ToList();
            var auctionImageUrls = await GetImagesUrlsForAuctionAsync(auctionIds);
            var offerCounts = await GetOffersForAuctionAsync(auctionIds);

            var result = paginatedAuctions.Select(a => new HomePageAuctionDTO
            {
                Id = a.Id,
                MainImageUrl = auctionImageUrls.ContainsKey(a.Id) && auctionImageUrls[a.Id].Any()
                    ? auctionImageUrls[a.Id].First()  // Extract the first image
                    : "No Image",
                Title = a.Title,
                Type = (AuctionType)a.AuctionType,
                CurrentPrice = a.CurrentPrice,
                Threshold = a.Threshold,
                ThresholdTimer = a.Timer,
                Offers = offerCounts.ContainsKey(a.Id) ? offerCounts[a.Id] : 0
            }).ToList();

            return new PaginatedResult<HomePageAuctionDTO>(result, totalRecords);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting home page auctions failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting home page auctions failed.", ex);
        }
    }

    private async Task<Dictionary<Guid, int>> GetOffersForAuctionAsync(List<Guid> auctionIds)
    {
        if (auctionIds == null || !auctionIds.Any())
            return new Dictionary<Guid, int>();

        try
        {
            return await _unitOfWork.BidRepository
                .Get(bid => auctionIds.Contains(bid.AuctionId))
                .GroupBy(bid => bid.AuctionId)
                .ToDictionaryAsync(group => group.Key, group => group.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SERVICE] Getting offer counts failed: {Message}", ex.Message);
            throw new Exception("[SERVICE] Getting offer counts failed.", ex);
        }
    }
    
    private async Task<Dictionary<Guid, List<string>>> GetImagesUrlsForAuctionAsync(List<Guid> auctionIds)
    {
        if (auctionIds == null || !auctionIds.Any())
            return new Dictionary<Guid, List<string>>();

        try
        {
            return await _unitOfWork.AuctionImageRepository
                .Get(image => auctionIds.Contains(image.AuctionId))
                .GroupBy(image => image.AuctionId)
                .ToDictionaryAsync(
                    group => group.Key,  // Auction ID as key
                    group => group.Select(image => image.Url).ToList() // List of image URLs as value
                );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SERVICE] Getting image URLs failed: {Message}", ex.Message);
            throw new Exception("[SERVICE] Getting image URLs failed.", ex);
        }
    }

}