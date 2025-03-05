using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class ImageService: IImageService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<ImageService> _logger;
    
    public ImageService(IUnitOfWork unitOfWork, ILogger<ImageService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }
    
    public async Task<Dictionary<Guid, List<string>>> GetImagesUrlsForAuctionAsync(List<Guid> auctionIds)
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

    // Overloaded method for getting image URLs for a single auction
    public async Task<List<string>> GetImagesUrlsForAuctionAsync(Guid auctionId)
    {
        try
        {
            return await _unitOfWork.AuctionImageRepository
                .Get(image => image.AuctionId == auctionId)
                .Select(image => image.Url)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SERVICE] Getting image URLs failed for Auction {AuctionId}: {Message}", auctionId, ex.Message);
            throw new Exception("[SERVICE] Getting image URLs failed.", ex);
        }
    }
}