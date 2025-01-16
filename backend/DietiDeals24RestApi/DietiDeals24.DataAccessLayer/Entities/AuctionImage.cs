using System;

namespace DietiDeals24.DataAccessLayer.Entities;

public class AuctionImage
{
    public Guid Id { get; set; }
    public Guid AuctionId { get; set; }
    public string Url { get; set; }

    // Navigation Properties
    public Auction Auction { get; set; }
}