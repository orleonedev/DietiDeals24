using System;

namespace DietiDeals24.DataAccessLayer.Entities;

public class Notification
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid AuctionId { get; set; }
    public NotificationType NotificationType { get; set; }
    public string Message { get; set; }
    public DateTime CreationDate { get; set; }
    public string AuctionTitle { get; set; }
    public string? MainImageUrl { get; set; }

    // Navigation Properties
    public User User { get; set; }
    public Auction Auction { get; set; }
}

public enum NotificationType
{
    AuctionExpired,
    AuctionBid,
    AuctionClosed
}