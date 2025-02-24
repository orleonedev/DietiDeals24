using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

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
        AuctionFilters filters, string? predicate = null, params object[] parameters)
    {
        try
        {
            var query = _unitOfWork.AuctionRepository.Get(
                auction => /*(filters.Category == null || auction.Category == filters.Category.Value) && */ //need to be fixed
                     (filters.Type == null || auction.AuctionType == filters.Type.Value) &&
                     (auction.CurrentPrice >= filters.MinPrice) &&
                     (auction.CurrentPrice <= filters.MaxPrice)
            );
            
            var totalRecords = await query.CountAsync();

            var paginatedAuctions = await query
                //.OrderBy(a => a.Id)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var auctionIds = paginatedAuctions.Select(auction => auction.Id).ToList();
            var auctionImageUrls = await GetImagesUrlsForAuctionAsync(auctionIds);
            var offerCounts = await GetOffersForAuctionAsync(auctionIds);

            var result = paginatedAuctions.Select(auction => new HomePageAuctionDTO
            {
                Id = auction.Id,
                MainImageUrl = auctionImageUrls.ContainsKey(auction.Id) && auctionImageUrls[auction.Id].Any()
                    ? auctionImageUrls[auction.Id].First()  // Extract the first image
                    : "No Image",
                Title = auction.Title,
                Type = (AuctionType) auction.AuctionType,
                CurrentPrice = auction.CurrentPrice,
                StartDate = auction.StartingDate,
                Threshold = auction.Threshold,
                ThresholdTimer = auction.Timer,
                Bids = offerCounts.ContainsKey(auction.Id) ? offerCounts[auction.Id] : 0
            })
            .OrderByDescending<HomePageAuctionDTO, object>(auction =>
            {
                return filters.Order switch
                {
                    AuctionSortOrder.MostBids => auction.Bids,
                    AuctionSortOrder.PriceHighToLow => auction.CurrentPrice,
                    AuctionSortOrder.PriceLowToHigh => -auction.CurrentPrice,
                    AuctionSortOrder.NewestFirst => auction.StartDate
                };
            })
            .ToList();

            return new PaginatedResult<HomePageAuctionDTO>(result, totalRecords);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting home page auctions failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting home page auctions failed.", ex);
        }
    }

    public async Task<DetailedAuctionDTO> CreateAuctionAsync(CreateAuctionDTO auction)
    {
        try
        {
            if (auction == null) throw new ArgumentNullException(nameof(auction), "[SERVICE] Auction DTO is null.");
            
            // Fetch vendor & category in parallel to improve efficiency
            var vendor = await _unitOfWork.VendorRepository
                .Get(vendor => vendor.Id == auction.VendorId)
                .FirstOrDefaultAsync();
            
            var category = await _unitOfWork.CategoryRepository
                .Get(category => category.Name.ToLower() == auction.Category.ToString().ToLower())
                .FirstOrDefaultAsync();

            if (vendor == null) throw new InvalidOperationException("[SERVICE] Vendor does not exist.");
            if (category == null) throw new InvalidOperationException("[SERVICE] Category does not exist.");

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
                AuctionState = AuctionState.Open,
                StartingDate = DateTime.Now,
                Vendor = vendor,
                Category = category
            };

            _unitOfWork.BeginTransaction();

            await _unitOfWork.AuctionRepository.Add(newAuction);
            //await _unitOfWork.Save(); // Save to generate the Auction ID

            // Create images if any exist
            var imageList = auction.ImagesUrls?
                .Select(imageUrl => new AuctionImage
                {
                    AuctionId = newAuction.Id,
                    Url = imageUrl,
                    Auction = newAuction
                }).ToList() ?? new List<AuctionImage>();

            if (imageList.Any())
            {
                await _unitOfWork.AuctionImageRepository.AddRange(imageList);
            }

            _unitOfWork.Commit(); // Commit only once after all operations
            await _unitOfWork.Save();

            return new DetailedAuctionDTO
            {
                Id = newAuction.Id,
                MainImageUrl = imageList.FirstOrDefault()?.Url, // Handle case where no images exist
                Title = newAuction.Title,
                Description = newAuction.AuctionDescription,
                Type = newAuction.AuctionType,
                Category = Enum.TryParse(category.Name, true, out AuctionCategory parsedCategory) 
                            ? parsedCategory 
                            : throw new InvalidOperationException("[SERVICE] Invalid category name."),
                CurrentPrice = newAuction.CurrentPrice,
                StartDate = newAuction.StartingDate,
                EndingDate = newAuction.EndingDate,
                Threshold = newAuction.Threshold,
                ThresholdTimer = newAuction.Timer,
                Bids = newAuction.Bids?.Count ?? 0
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Creating new auction failed: {ex.Message}");
            throw new Exception("[SERVICE] Creating new auction failed.", ex);
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