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