using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.RestApi.Workers;

public interface INotificationWorker
{
    public Task AddNotificationTokenAsync(Guid userId, string deviceToken);
    public Task RemoveNotificationTokenAsync(string deviceToken);
    public Task SendNotificationAsync(Guid userId, NotificationDTO notification);
}