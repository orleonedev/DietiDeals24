using System.Text.Json;
using Amazon.SimpleNotificationService;
using Amazon.SimpleNotificationService.Model;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;
using DietiDeals24.RestApi.Models;
using Exception = System.Exception;

namespace DietiDeals24.RestApi.Workers.Impl;

public class NotificationWorker: INotificationWorker
{
    private readonly ILogger<NotificationWorker> _logger;
    private readonly INotificationService _notificationService;
    private readonly IAmazonSimpleNotificationService _snsClient;
    private readonly string _platformApplicationArn;

    public NotificationWorker(ILogger<NotificationWorker> logger, 
        INotificationService notificationService, 
        IAmazonSimpleNotificationService snsClient)
    {
        _logger = logger;
        _notificationService = notificationService;
        _snsClient = snsClient;
        _platformApplicationArn = Environment.GetEnvironmentVariable("SNS_PLATFORM_ARN");
    }

    public async Task<PaginatedResult<NotificationDTO>> GetPaginatedNotificationsForUserIdAsync(NotificationFiltersDTO filters)
    {
        _logger.LogInformation($"[WORKER] Getting paginated notifications for user {filters.UserId}");

        try
        {
            var notifications = await _notificationService.GetPaginatedNotificationsForUserIdAsync(filters.UserId, filters.Page, filters.PageSize);
            var paginatedNotifications = new PaginatedResult<NotificationDTO>
            {
                Results = new List<NotificationDTO>(),
                TotalRecords = notifications.Count,
                PageNumber = filters.Page,
                PageSize = filters.PageSize
            };

            foreach (var notification in notifications)
            {
                paginatedNotifications.Results.Add(new NotificationDTO
                {
                    Id = notification.Id,
                    Type = notification.NotificationType,
                    CreationDate = notification.CreationDate,
                    Message = notification.Message,
                    MainImageUrl = notification.MainImageUrl,
                    AuctionId = notification.AuctionId,
                    AuctionTitle = notification.AuctionTitle
                });
            }
            
            return paginatedNotifications;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Getting paginated notifications failed for user {filters.UserId}: {ex.Message}");
            return null;
        }
    }

    public async Task AddNotificationTokenAsync(Guid userId, string deviceToken)
    {
        _logger.LogInformation($"[WORKER] Adding notification token for user {userId}.");
        string? alreadyRegisteredToken = await _notificationService.GetEndPointArnFromDeviceTokenAsync(deviceToken);

        if (alreadyRegisteredToken.Any())
        {
            _logger.LogInformation($"[WORKER] Adding notification token failed for user {userId}: Device token {deviceToken} was already registered.");
            return;
        }

        try
        {
            // Step 1: Register Device with AWS SNS
            var createEndpointResponse = await _snsClient.CreatePlatformEndpointAsync(new CreatePlatformEndpointRequest
            {
                PlatformApplicationArn = _platformApplicationArn,
                Token = deviceToken, // push notification token (from Firebase or APNs)
                CustomUserData = userId.ToString() // Store user reference in AWS
            });

            string endpointArn = createEndpointResponse.EndpointArn;
            _logger.LogInformation($"[WORKER] SNS Endpoint Created: {endpointArn} for user {userId}.");

            // Step 2: Store the Endpoint ARN instead of the raw device ID
            await _notificationService.AddNotificationTokenAsync(userId, deviceToken, endpointArn);

            _logger.LogInformation($"[WORKER] Successfully added notification token for user {userId}.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Adding notification token failed for user {userId}: {ex.Message}");
            throw new Exception($"[WORKER] Adding notification token failed for user {userId}: {ex.Message}.", ex);
        }
    }

    public async Task RemoveNotificationTokenAsync(string deviceToken)
    {
        _logger.LogInformation($"[WORKER] Removing notification token for device token {deviceToken}.");

        try
        {
            // Retrieve the stored SNS Endpoint ARN from the database
            string? endpointArn = await _notificationService.GetEndPointArnFromDeviceTokenAsync(deviceToken);
        
            if (string.IsNullOrEmpty(endpointArn))
            {
                _logger.LogWarning($"[WORKER] No SNS endpoint found for device token {deviceToken}.");
                return;
            }

            // Delete the Endpoint ARN from AWS SNS
            await _snsClient.DeleteEndpointAsync(new DeleteEndpointRequest
            {
                EndpointArn = endpointArn
            });

            _logger.LogInformation($"[WORKER] SNS Endpoint {endpointArn} deleted for device token {deviceToken}.");

            // Remove the device token from the database
            await _notificationService.RemoveNotificationTokenAsync(deviceToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Removing notification token failed for device token {deviceToken}: {ex.Message}");
            throw new Exception($"[WORKER] Removing notification token failed for device token {deviceToken}: {ex.Message}.", ex);
        }
    }

    public async Task SendNotificationAsync(Guid userId, NotificationDTO notificationDto)
    {
        try
        {
            _logger.LogInformation($"[WORKER] Storing notification for user {userId}.");
            await _notificationService.AddNotificationAsync(notificationDto, userId);
            _logger.LogInformation($"[WORKER] Notification for user {userId} was stored.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Storing notification failed for user {userId}: {ex.Message}");
            return;
        }
        
        List<string> endpointArns;
        // Retrieve the user's endpoint ARNs from the database
        try
        {
            _logger.LogInformation($"[WORKER] Sending notification to user {userId}.");

            endpointArns = await _notificationService.GetEndPointArnFromUserIdAsync(userId);
            if (!endpointArns.Any())
            {
                _logger.LogWarning($"[WORKER] No endpoints found for user {userId}.");
                return;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Error in retrieving endpoints for user {userId}: {ex.Message}");
            return;
        }

        string notificationTitle;

        switch (notificationDto.Type)
        {
            case NotificationType.AuctionExpired:
                notificationTitle = "Auction expired";
                break;
            case NotificationType.AuctionBid:
                notificationTitle = "New Bid";
                break;
            case NotificationType.AuctionClosed:
                notificationTitle = "Auction Closed";
                break;
            default:
                notificationTitle = "Unknown Notification Type";
                _logger.LogWarning($"[WORKER] Unknown notification type: {notificationDto.Type}");
                break;
        }

        var jsonPayload = PushNotificationTemplate.GetPushString(notificationTitle, notificationDto.Message,
            notificationDto.AuctionTitle, notificationDto.AuctionId);

        foreach (var endpointArn in endpointArns)
            try
            {
                _logger.LogInformation($"[WORKER] Creating Push Configuration for endpoint {endpointArn}.");
                // Send the notification
                var publishRequest = new PublishRequest
                {
                    TargetArn = endpointArn,
                    MessageStructure = "json",
                    Message = JsonSerializer.Serialize(new
                    {
                        APNS = jsonPayload // Wrap the APNs payload in APNS
                    })
                };
                await _snsClient.PublishAsync(publishRequest);
                _logger.LogInformation($"[WORKER] Notification sent to endpoint {endpointArn}.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"[WORKER] Sending notification failed for user {userId}: {ex.Message}");
            }

        _logger.LogInformation($"[WORKER] Notifications sent to every endpoint for user {userId}.");
    }
}