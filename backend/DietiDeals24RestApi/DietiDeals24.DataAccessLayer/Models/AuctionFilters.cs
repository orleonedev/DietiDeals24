using System;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Models;

public class AuctionFilters
{
    public AuctionCategory? Category { get; set; } = AuctionCategory.Goods;
    public AuctionType? Type { get; set; } = AuctionType.Incremental;
    public AuctionSortOrder? Order { get; set; } = AuctionSortOrder.MostBids; // Sorting order
    public decimal? MinPrice { get; set; } = Decimal.Zero; // Minimum price range
    public decimal? MaxPrice { get; set; } = Decimal.MaxValue; // Maximum price range
}