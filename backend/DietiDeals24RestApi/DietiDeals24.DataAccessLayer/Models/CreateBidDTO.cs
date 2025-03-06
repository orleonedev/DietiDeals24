using System;

namespace DietiDeals24.DataAccessLayer.Models;

public class CreateBidDTO
{
    public Guid AuctionId { get; set; }
    public Guid BuyerId { get; set; }
    public decimal Price { get; set; }
}