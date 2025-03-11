using System;

namespace DietiDeals24.DataAccessLayer.Entities;

public class Bid
{
    public Guid Id { get; set; }
    public Guid AuctionId { get; set; }
    public Guid BuyerId { get; set; }
    public decimal Price { get; set; }
    public DateTime BidDate { get; set; }

    // Navigation Properties
    public Auction Auction { get; set; }
    public User Buyer { get; set; }
}