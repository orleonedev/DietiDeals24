using System;
using System.Collections.Generic;

namespace DietiDeals24.DataAccessLayer.Entities;

public class User
{
    public Guid Id { get; set; } 
    public string CognitoSub { get; set; }
    public string Username { get; set; }
    public string Fullname { get; set; }
    public string Email { get; set; }
    public UserRole Role { get; set; }
    public DateTime BirthDate { get; set; }
    public bool HasVerifiedEmail { get; set; }
    
    // Navigation Properties
    public Vendor Vendor { get; set; }
    public ICollection<Bid> Bids { get; set; }
    public ICollection<Notification> Notifications { get; set; }
    public ICollection<UserPushToken> UserPushTokens { get; set; }
}

public enum UserRole
{
    Buyer,
    Seller
}