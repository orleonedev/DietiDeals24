using System;

namespace DietiDeals24.DataAccessLayer.Models;

public class CreateVendorDTO
{
    public Guid UserId { get; set; }
    public string? GeoLocation { get; set; }
    public string? WebSiteUrl { get; set; }
    public string? ShortBio { get; set; }
}

public class UpdateVendorDTO
{
    public Guid VendorId { get; set; }
    public string? GeoLocation { get; set; }
    public string? WebSiteUrl { get; set; }
    public string? ShortBio { get; set; }
}

public class DetailedVendorDTO
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public int? SuccessfulAuctions { get; set; }
    public DateTime JoinedSince { get; set; }
    public string? GeoLocation { get; set; }
    public string? WebSiteUrl { get; set; }
    public string? ShortBio { get; set; }
}