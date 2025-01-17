using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
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

    public Task<List<Auction>> GetAllAuctionsAsync()
    {
        throw new NotImplementedException();
    }

    public Task<List<Auction>> GetAllAuctionsAsync(int skip, int limit)
    {
        throw new NotImplementedException();
    }
}