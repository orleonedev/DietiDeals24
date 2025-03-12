using System;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Models;

public class UserPushTokenDTO
{
    public Guid UserId { get; set; }
    public string DeviceToken { get; set; }
}

public class NotificationDTO
{
    public Guid Id { get; set; }
    public NotificationType Type { get; set; }
    public DateTime CreationDate { get; set; }
    public string Message { get; set; }
    public string MainImageUrl { get; set; }
    public Guid AuctionId { get; set; }
    public string AuctionTitle { get; set; }
}

public class NotificationFiltersDTO
{
    public int Page { get; set; }
    public int PageSize { get; set; }
    public Guid UserId { get; set; }
}