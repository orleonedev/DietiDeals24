using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class NotificationService: INotificationService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<NotificationService> _logger;
    
    public NotificationService(IUnitOfWork unitOfWork, ILogger<NotificationService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<List<Notification>> GetPaginatedNotificationsForUserIdAsync(Guid userId, int page, int pageSize)
    {
        _logger.LogInformation($"[SERVICE] Getting all notifications for user {userId}");

        try
        {
            var notifications = await _unitOfWork.NotificationRepository
                .Get(notification => notification.UserId == userId)
                .OrderByDescending(n => n.CreationDate)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return notifications;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Failed getting all notifications for user {userId}. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Getting all notifications for user {userId}. Exception occurred: {ex.Message}");
        }
    }

    public async Task<UserPushToken> AddNotificationTokenAsync(Guid userId, string deviceToken, string endPointArn)
    {
        _logger.LogInformation($"[SERVICE] Adding notification token for user {userId}, deviceToken {deviceToken} and endPointArn {endPointArn}.");

        try
        {
            DateTime now = DateTime.Now;
            DateTime actualDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
            
            var userPushToken = new UserPushToken
            {
                UserId = userId,
                DeviceToken = deviceToken,
                EndPointArn = endPointArn,
                RegistrationDate = actualDate
            };
                
            _unitOfWork.BeginTransaction();
            await _unitOfWork.UserPushTokenRepository.Add(userPushToken);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

            return userPushToken;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Adding notification token failed for user {userId}, deviceToken {deviceToken} and endPointArn {endPointArn}: {ex.Message}", ex.Message);
            throw new Exception($"[SERVICE] Adding notification token failed for user {userId}, deviceToken {deviceToken} and endPointArn {endPointArn}: {ex.Message}.", ex);
        }
    }

    public async Task<Notification> AddNotificationAsync(NotificationDTO notificationDto, Guid userId)
    {
        _logger.LogInformation($"[SERVICE] Adding notification entity for user {userId}.");

        try
        {
            DateTime now = DateTime.Now;
            DateTime creationDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
            
            var notification = new Notification
            {
                UserId = userId,
                AuctionId = notificationDto.AuctionId,
                NotificationType = notificationDto.Type,
                Message = notificationDto.Message,
                CreationDate = creationDate,
                AuctionTitle = notificationDto.AuctionTitle,
                MainImageUrl = notificationDto.MainImageUrl
            };
            
            _unitOfWork.BeginTransaction();
            await _unitOfWork.NotificationRepository.Add(notification);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

            return notification;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Adding notification entity failed.");
            return null;
        }
    }

    public async Task<List<string>> GetEndPointArnFromUserIdAsync(Guid userId)
    {
        _logger.LogInformation($"[SERVICE] Getting endpoint for user {userId}.");

        try
        {
            var endpoint = await _unitOfWork.UserPushTokenRepository
                .Get(token => token.UserId == userId)
                .Select(token => token.EndPointArn)
                .ToListAsync();

            return endpoint;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting endpoint failed for user {userId}: {ex.Message}", ex.Message);
            throw new Exception($"[SERVICE] Getting endpoint failed for user {userId}: {ex.Message}.", ex);
        }
    }
    
    public async Task<string> GetEndPointArnFromDeviceTokenAsync(string deviceToken)
    {
        _logger.LogInformation($"[SERVICE] Getting endpoint for device token {deviceToken}.");

        try
        {
            var endpoint = await _unitOfWork.UserPushTokenRepository
                .Get(token => token.DeviceToken == deviceToken)
                .FirstOrDefaultAsync();
            
            return endpoint?.EndPointArn ?? "" ;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting endpoint failed for device token {deviceToken}: {ex.Message}", ex.Message);
            throw new Exception($"[SERVICE] Getting endpoint failed for device token {deviceToken}: {ex.Message}.", ex);
        }
    }
    
    public async Task RemoveNotificationTokenAsync(string deviceToken)
    {
        _logger.LogInformation($"[SERVICE] Removing notification {deviceToken}.");

        try
        {
            var token = await _unitOfWork.UserPushTokenRepository
                .Get(token => token.DeviceToken == deviceToken)
                .FirstOrDefaultAsync();

            if (token == null)
            {
                _logger.LogWarning($"[SERVICE] Device token {deviceToken} is not active.");
                return;
            }
            
            _unitOfWork.BeginTransaction();
            await _unitOfWork.UserPushTokenRepository.Delete(token.Id);
            _unitOfWork.Commit();
            await _unitOfWork.Save();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Removing notification {deviceToken} failed: {ex.Message}", ex.Message);
            throw new Exception($"[SERVICE] Removing notification {deviceToken} failed: {ex.Message}.", ex);
        }
    }
}