
using System;
using System.Collections;
using System.Collections.Generic;
using System.Timers;

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


public enum AuctionStatus
{
    Active,
    Finished
}

public enum AuctionType {
    EnglishLike = 0,
    Reverse = 1
}

public class HomePageAuctionDTO
{
    //public Image Image { get; set; }
    public Guid Id { get; set; }
    public string Title { get; set; }
    public AuctionType Type { get; set; }
    public decimal CurrentPrice { get; set; }
    public decimal Threshold { get; set; }
    public int ThresholdTimer { get; set; }
    public int? Offers { get; set; }
}

public class DetailedAuctionDTO
{
    public string Title { get; set; }
    //public List<Image> Images { get; set; }
    public string Category { get; set; }
    public string AuctionType { get; set; }
    public decimal CurrentPrice { get; set; }
    public decimal Threshold { get; set; }
    public DateTime EndingTime { get; set; }
    public int ThresholdTimer { get; set; }
    public int? Offers { get; set; }
    public string Description { get; set; }
}
