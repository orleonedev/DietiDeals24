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
    public Guid CategoryId { get; set; }
    public AuctionState AuctionState { get; set; }
    public DateTime StartingDate { get; set; }
    public DateTime EndingDate { get; set; }

    // Navigation Properties
    public Vendor Vendor { get; set; }
    public Category Category { get; set; }
    public ICollection<AuctionImage> AuctionImages { get; set; }
    public ICollection<Bid> Bids { get; set; }
    //public ICollection<Transaction> Transactions { get; set; }
}

public enum AuctionType
{
    Incremental,
    Descending
}

public enum AuctionState
{
    Open,
    Closed,
    Expired
}
