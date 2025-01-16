using System;
using System.Collections.Generic;

namespace DietiDeals24.DataAccessLayer.Entities;

public class Category
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    
    // navigation Property
    public ICollection<Auction> Auctions { get; set; }
}