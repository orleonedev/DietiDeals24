using System;
using System.Collections.Generic;

namespace DietiDeals24.DataAccessLayer.Entities;

public class Auction
{
    public Guid Id { get; set; }
    public string Title { get; set; }
    public string AuctionDescription { get; set; }
    public decimal StartingPrice { get; set; }
    public decimal CurrentPrice { get; set; }
    public AuctionType AuctionType { get; set; }
    public decimal Threshold { get; set; }
    public int Timer { get; set; }
    public decimal? SecretPrice { get; set; }
    public Guid VendorId { get; set; }
    public AuctionCategory Category { get; set; }
    public AuctionState AuctionState { get; set; }
    public DateTime StartingDate { get; set; }
    public DateTime EndingDate { get; set; }

    // Navigation Properties
    public Vendor Vendor { get; set; }
    public ICollection<AuctionImage> AuctionImages { get; set; } = new List<AuctionImage>();
    public ICollection<Bid> Bids { get; set; } = new List<Bid>();
    //public ICollection<Transaction> Transactions { get; set; }
}

public enum AuctionType
{
    All = 0,
    Incremental = 1,
    Descending = 2
}

public enum AuctionState
{
    Open = 0,
    Closed = 1,
    Expired = 2
}

public enum AuctionCategory
{
    All = 0,
    Services = 1,
    Electronics = 2,
    Furniture = 3,
    Clothing = 4
}

public enum AuctionSortOrder
{
    MostBids = 0,
    NewestFirst = 1,
    PriceLowToHigh = 2,
    PriceHighToLow = 3
}
