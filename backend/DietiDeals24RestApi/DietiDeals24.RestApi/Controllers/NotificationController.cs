using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.RestApi.Workers;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.AspNetCore.Mvc;

namespace DietiDeals24.RestApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NotificationController : ControllerBase
{
    private readonly ILogger<NotificationController> _logger;
    private readonly INotificationWorker _notificationWorker;

    public NotificationController(ILogger<NotificationController> logger, INotificationWorker notificationWorker)
    {
        _logger = logger;
        _notificationWorker = notificationWorker;
    }

    [HttpPost("get-notifications", Name = "GetNotifications")]
    [ProducesResponseType(typeof(IEnumerable<Notification>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetNotifications([FromBody] NotificationFiltersDTO filters)
    {
        _logger.LogInformation($"[CONTROLLER] Getting notifications for {filters.UserId}");

        try
        {
            var result = await _notificationWorker.GetPaginatedNotificationsForUserIdAsync(filters);
            return Ok(result.Results);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Getting notifications for {filters.UserId}. Exception occurred: {ex.Message}");
            return Problem();
        }
    }

    [HttpPost("add-notification-token", Name = "AddNotificationToken")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AddNotificationToken([FromBody] UserPushTokenDTO userPushTokenDto)
    {
        _logger.LogInformation($"[CONTROLLER] Adding notification token for user {userPushTokenDto.UserId}.");
        
        try
        {
            await _notificationWorker.AddNotificationTokenAsync(userPushTokenDto.UserId, userPushTokenDto.DeviceToken);
            
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to add notification token for user {userPushTokenDto.UserId}. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("remove-notification-token", Name = "RemoveNotificationToken")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> RemoveNotificationToken([FromBody] string deviceToken)
    {
        try
        {
            await _notificationWorker.RemoveNotificationTokenAsync(deviceToken);
            
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to remove notification token for device {deviceToken}. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
}