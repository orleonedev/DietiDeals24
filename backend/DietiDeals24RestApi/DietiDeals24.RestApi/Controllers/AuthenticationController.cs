using DietiDeals24.RestApi.Workers;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DietiDeals24.RestApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthenticationController : ControllerBase
{
    private readonly ILogger<AuthenticationController> _logger;
    private readonly IAuthenticationWorker _authenticationWorker;

    public AuthenticationController(ILogger<AuthenticationController> logger, IAuthenticationWorker authenticationWorker)
    {
        _logger = logger;
        _authenticationWorker = authenticationWorker;
    }

    [HttpPost("register-user", Name = "RegisterUser")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RegisterUser([FromBody] RegistrationDTO model)
    {
        try
        {
            var response = await _authenticationWorker.RegisterUserAsync(model);
            
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to register user. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("login", Name = "Login")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Login([FromBody] LoginDTO model)
    {
        try
        {
            var response = await _authenticationWorker.LoginUserAsync(model);
            
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to login user. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("logout", Name = "Logout")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Logout([FromBody] LogoutDTO model)
    {
        try
        {
            await _authenticationWorker.LogoutUserAsync(model);
            
            return Ok("User logged out successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to logout user. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("confirm-user", Name = "ConfirmUser")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ConfirmUser([FromBody] ConfirmUserDTO model)
    {
        try
        {
            await _authenticationWorker.ConfirmUserAsync(model);

            return Ok("User confirmed successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to confirm user email. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
    
    [HttpPost("resend-confirmation-code", Name = "ResendConfirmationCode")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResendConfirmationCode([FromBody] ResendCodeDTO model)
    {
        try
        {
            await _authenticationWorker.ResendConfirmationCodeAsync(model);

            return Ok("Confirmation code resended successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to resend confirmation code. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("refresh-token", Name = "RefreshToken")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenDTO model)
    {
        try
        {
            var response = await _authenticationWorker.RefreshTokenAsync(model);
            
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to refresh token. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("get-secure-data")]
    [Authorize]
    public IActionResult GetSecureData()
    {
        return Ok("This is secure data!");
    }
}