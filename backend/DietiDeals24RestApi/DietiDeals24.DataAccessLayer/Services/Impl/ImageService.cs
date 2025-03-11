using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Amazon.S3;
using Amazon.S3.Model;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class ImageService: IImageService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<ImageService> _logger;
    private readonly IAmazonS3 _s3Client;
    private readonly string _bucketName = "sigma63-dietideals24-auction-images";
    
    public ImageService(IUnitOfWork unitOfWork, ILogger<ImageService> logger, IAmazonS3 s3Client)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
        _s3Client = s3Client;
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

    public async Task<Dictionary<Guid, string>> AddImagesUrlsForAuctionAsync(Guid auctionId, List<Guid> imagesId)
    {
        try
        {
            var auctionImages = new List<AuctionImage>();
            var imagesDict = new Dictionary<Guid, string>();

            foreach (var imageId in imagesId)
            {
                var auctionImage = new AuctionImage
                {
                    Id = imageId,
                    AuctionId = auctionId,
                    Url = $"https://{_bucketName}.s3.amazonaws.com/auction-{auctionId}/{imageId}.jpeg"
                };
                
                auctionImages.Add(auctionImage);

                var presignedUrl = await GetPresignedUrlAsync(auctionId, imageId);
                imagesDict.Add(imageId, presignedUrl);
            }
            
            _unitOfWork.BeginTransaction();
            await _unitOfWork.AuctionImageRepository.AddRange(auctionImages);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

            return imagesDict;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Adding images failed for Auction {auctionId}: {ex.Message}", ex.Message);
            throw new Exception($"[SERVICE] Adding images failed for Auction {auctionId}: {ex.Message}", ex);
        }
    } 
    
    private async Task<string> GetPresignedUrlAsync(Guid auctionId, Guid imageId)
    {
        string objectKey = $"auction-{auctionId}/{imageId}.jpeg";

        var request = new GetPreSignedUrlRequest
        {
            BucketName = _bucketName,
            Key = objectKey,
            Verb = HttpVerb.PUT,
            Expires = DateTime.UtcNow.AddMinutes(10), // URL valid for 10 minutes
            ContentType = "image/jpeg"
        };

        return _s3Client.GetPreSignedURL(request);
    }
}