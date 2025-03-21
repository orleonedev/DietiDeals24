using System;
using System.Collections.Generic;

namespace DietiDeals24.DataAccessLayer.Entities;

public class Vendor
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string? GeoLocation { get; set; }
    public string? WebSiteUrl { get; set; }
    public string? ShortBio { get; set; }
    public DateTime StartingDate { get; set; }
    public int SuccessfulAuctions { get; set; }

    // Navigation Property
    public User User { get; set; } 
    public ICollection<Auction> Auctions { get; set; }
    //public ICollection<Transaction> Transactions { get; set; }
}