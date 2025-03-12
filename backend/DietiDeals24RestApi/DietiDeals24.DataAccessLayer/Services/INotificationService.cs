using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface INotificationService
{
    public Task<List<Notification>> GetAllNotificationsForUserIdAsync(Guid userId);
    public Task<UserPushToken> AddNotificationTokenAsync(Guid userId, string deviceToken, string endPointArn);
    public Task<Notification> AddNotificationAsync(NotificationDTO notificationDto, Guid userId);
    public Task<List<string>> GetEndPointArnFromUserIdAsync(Guid userId);
    public Task<string> GetEndPointArnFromDeviceTokenAsync(string deviceToken);
    public Task RemoveNotificationTokenAsync(string deviceToken);
}