using System.Reflection;
using DietiDeals24.RestApi.Workers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DietiDeals24.RestApi.Controllers;

/// <summary>
/// Controller for performing system checks.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class CheckController : ControllerBase
{
    private readonly ILogger<CheckController> _logger;
    private readonly ICheckWorker _checkWorker;
    
    /// <summary>
    /// Initializes a new instance of the <see cref="CheckController"/> class.
    /// </summary>
    /// <param name="logger">The logger instance for logging operations.</param>
    /// <param name="checkWorker">The worker instance for performing checks</param>
    public CheckController(ILogger<CheckController> logger, ICheckWorker checkWorker )
    {
        _logger = logger;
        _checkWorker = checkWorker;
    }

    /// <summary>
    /// Retrieves the current ASP.NET Core environment.
    /// </summary>
    /// <returns>
    /// The ASP.NET Core environment as a string (e.g., "Development", "Production").
    /// </returns>
    /// <response code="200">Returns the current environment.</response>
    [HttpGet("environment", Name = "CheckEnvironment")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetEnvironment()
    {
        _logger.LogInformation("Checking Environment");
        var env = await _checkWorker.GetEnvironmentValue();
        return Ok(env);
    }
    
    /// <summary>
    /// Retrieves basic system information about the application.
    /// </summary>
    /// <returns>Returns system information such as application version, machine name, etc.</returns>
    /// <response code="200">Returns the system information.</response>
    [HttpGet("system-info", Name = "GetSystemInfo")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetSystemInfo()
    {
        _logger.LogInformation("Checking System Info");
        return Ok( await _checkWorker.GetSystemInfos());
    }
    
    /// <summary>
    /// A simple ping endpoint to check if the application is running.
    /// </summary>
    /// <returns>Returns a 200 OK response indicating the application is alive.</returns>
    [HttpGet("ping", Name = "Ping")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public IActionResult Ping()
    {
        _logger.LogInformation("Pinging");
        return Ok("Application is alive");
    }

    /// <summary>
    /// Checks if the database connection is working.
    /// </summary>
    /// <returns>Returns a 200 OK response if the database is reachable.</returns>
    /// <response code="200">Database is reachable.</response>
    /// <response code="500">Database is not reachable.</response>
    [HttpGet("db-connection", Name = "CheckDbConnection")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> CheckDatabaseConnection()
    {
        var result = await _checkWorker.CheckDatabaseConnection();
        return result ? Ok("Database is connected.") : StatusCode(StatusCodes.Status500InternalServerError, "Database is unavailable.");
    }

}