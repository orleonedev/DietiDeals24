using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Models;

public class PaginatedResult<T>
{
    public int TotalRecords { get; set; } = 0; // Total number of records in db
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 4;
    public ICollection<T> Results { get; set; } = new List<T>(); // Result list paginated

    public PaginatedResult() {}

    public PaginatedResult(List<T> results, int totalRecords)
    {
        Results = results;
        TotalRecords = totalRecords;
    }
}

public class HomePageAuctionDTO
{
    public Guid Id { get; set; }
    public string? MainImageUrl { get; set; } = null;
    public string Title { get; set; }
    public AuctionType Type { get; set; }
    public decimal CurrentPrice { get; set; }
    public DateTime EndingDate { get; set; }
    public int? Bids { get; set; }
}

public class DetailedAuctionDTO: HomePageAuctionDTO
{
    public string Description { get; set; }
    public List<string>? ImagesUrls { get; set; } = null;
    public AuctionCategory Category { get; set; }
    public DateTime StartingDate { get; set; }
    public decimal Threshold { get; set; }
    public int ThresholdTimer { get; set; }
    public Guid VendorId { get; set; }
    public string VendorName { get; set; }
    public decimal? SecretPrice { get; set; }
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
    public List<string>? ImagesUrls { get; set; } = null;
    public decimal? SecretPrice { get; set; } = null;
    public Guid VendorId { get; set; }
}
