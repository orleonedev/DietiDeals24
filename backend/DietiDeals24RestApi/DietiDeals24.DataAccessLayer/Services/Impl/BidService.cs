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

public class BidService: IBidService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<BidService> _logger;
    
    public BidService(IUnitOfWork unitOfWork, ILogger<BidService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }
    
    public async Task<Dictionary<Guid, int>> GetBidsCountForAuctionAsync(List<Guid> auctionIds)
    {
        if (auctionIds == null || !auctionIds.Any())
            return new Dictionary<Guid, int>();

        _logger.LogInformation($"[SERVICE] Getting bid count for AuctionIds List.");

        try
        {
            return await _unitOfWork.BidRepository
                .Get(bid => auctionIds.Contains(bid.AuctionId))
                .GroupBy(bid => bid.AuctionId)
                .ToDictionaryAsync(group => group.Key, group => group.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SERVICE] Getting bids for auctions failed: {Message}", ex.Message);
            throw new Exception("[SERVICE] Getting bids for auctions failed.", ex);
        }
    }
    
    // Overloaded method for getting offer count for a single auction
    public async Task<int> GetBidsCountForAuctionAsync(Guid auctionId)
    {
        _logger.LogInformation($"[SERVICE] Getting bid count for AuctionId: {auctionId}.");

        try
        {
            return await _unitOfWork.BidRepository
                .Get(bid => bid.AuctionId == auctionId)
                .CountAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting bids count failed for Auction {auctionId}: {ex.Message}", auctionId, ex.Message);
            throw new Exception($"[SERVICE] Getting bids count failed for Auction {auctionId}: {ex.Message}.", ex);
        }
    }

    public async Task<Bid> CreateBidAsync(CreateBidDTO bidDto, Auction auction)
    {
        _logger.LogInformation($"[SERVICE] Creating bid for Auction: {bidDto.AuctionId}");

        var user = await _unitOfWork.UserRepository
            .Get(user => user.Id == bidDto.BuyerId)
            .FirstOrDefaultAsync();

        if (user == null)
        {
            throw new ArgumentNullException($"User {bidDto.BuyerId} does not exist.");
        }

        try
        {
            DateTime now = DateTime.Now;
            DateTime bidDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);

            var newBid = new Bid
            {
                AuctionId = bidDto.AuctionId,
                BuyerId = bidDto.BuyerId,
                Price = bidDto.Price,
                BidDate = bidDate
            };
            
            _unitOfWork.BeginTransaction();
            await _unitOfWork.BidRepository.Add(newBid);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

            return newBid;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Creating new bid failed for Auction {bidDto.AuctionId}: {ex.Message}", bidDto.AuctionId, ex.Message);
            throw new Exception($"[SERVICE] Creating new bid failed for Auction {bidDto.AuctionId}: {ex.Message}.", ex);
        }
    }
}