using System;
using System.Collections.Generic;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Models;

public class PaginatedResult<T>
{
    public int TotalRecords { get; set; } // Total number of records in db
    public IEnumerable<T> Results { get; set; } = new List<T>(); // Result list paginated

    public PaginatedResult() {}

    public PaginatedResult(IEnumerable<T> results, int totalRecords)
    {
        Results = results;
        TotalRecords = totalRecords;
    }
}

public class HomePageAuctionDTO
{
    public string? MainImageUrl { get; set; }
    public Guid Id { get; set; }
    public string Title { get; set; }
    public AuctionType Type { get; set; }
    public decimal CurrentPrice { get; set; }
    public DateTime StartDate { get; set; }
    public decimal Threshold { get; set; }
    public int ThresholdTimer { get; set; } 
    public int? Bids { get; set; }
}

public class DetailedAuctionDTO: HomePageAuctionDTO
{
    //public string Title { get; set; }
    public List<string>? ImagesUrls { get; set; }
    public AuctionCategory Category { get; set; }
    //public string AuctionType { get; set; }
    //public decimal CurrentPrice { get; set; }
    //public decimal Threshold { get; set; }
    public DateTime EndingDate { get; set; }
    //public int ThresholdTimer { get; set; }
    //public int? Bids { get; set; }
    public string Description { get; set; }
}

public class CreateAuctionDTO
{
    public string Title { get; set; }
    public string Description { get; set; }
    public AuctionType Type { get; set; }
    public AuctionCategory Category { get; set; }
    public decimal StartingPrice { get; set; }
    public decimal Threshold { get; set; }
    public int ThresholdTimer { get; set; } 
    public List<string>? ImagesUrls { get; set; }
    public decimal? SecretPrice { get; set; }
    public Guid VendorId { get; set; }
}
