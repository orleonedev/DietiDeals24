using System;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Models;

public class AuctionFiltersDTO
{
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 4;
    public string? SearchText { get; set; }
    public AuctionCategory? Category { get; set; }
    public AuctionType? Type { get; set; }
    public AuctionSortOrder? Order { get; set; } = AuctionSortOrder.MostBids; // Sorting order
    public decimal? MinPrice { get; set; } = Decimal.Zero; // Minimum price range
    public decimal? MaxPrice { get; set; } = Decimal.MaxValue; // Maximum price range
    public Guid? VendorId { get; set; }
}