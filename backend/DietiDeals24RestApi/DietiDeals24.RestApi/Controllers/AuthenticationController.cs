using DietiDeals24.RestApi.Workers;
using DietiDeals24.RestApi.Models;
using Microsoft.AspNetCore.Mvc;

namespace DietiDeals24.RestApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthenticationController : ControllerBase
{
    private readonly ILogger<AuctionController> _logger;
    private readonly IAuthenticationWorker _authenticationWorker;

    public AuthenticationController(ILogger<AuctionController> logger, IAuthenticationWorker authenticationWorker)
    {
        _logger = logger;
        _authenticationWorker = authenticationWorker;
    }

    [HttpPost("register-user", Name = "RegisterUser")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RegisterUser([FromBody] RegistrationDTO model)
    {
        var response = await _authenticationWorker.RegisterUserAsync(model);
        return Ok(response);
    }
}