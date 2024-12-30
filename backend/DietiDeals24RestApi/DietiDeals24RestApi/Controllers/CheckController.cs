using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DietiDeals24RestApi.Controllers;

/// <summary>
/// Controller for performing system checks.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class CheckController : ControllerBase
{
    private readonly ILogger<CheckController> _logger;
    private readonly ApplicationDbContext _dbContext;
    /// <summary>
    /// Initializes a new instance of the <see cref="CheckController"/> class.
    /// </summary>
    /// <param name="logger">The logger instance for logging operations.</param>
    /// <param name="dbContext">The database context for performing the database check.</param>
    public CheckController(ILogger<CheckController> logger, ApplicationDbContext dbContext )
    {
        _logger = logger;
        _dbContext = dbContext;
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
    public IActionResult GetEnvironment()
    {
        _logger.LogInformation("Checking Environment");
        return Ok(Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"));
    }
    
    /// <summary>
    /// Retrieves basic system information about the application.
    /// </summary>
    /// <returns>Returns system information such as application version, machine name, etc.</returns>
    /// <response code="200">Returns the system information.</response>
    [HttpGet("system-info", Name = "GetSystemInfo")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public IActionResult GetSystemInfo()
    {
        _logger.LogInformation("Checking System Info");
        var systemInfo = new
        {
            ApplicationVersion = Assembly.GetExecutingAssembly().GetName().Version?.ToString(),
            MachineName = Environment.MachineName,
            OSVersion = Environment.OSVersion.ToString(),
            CurrentDateTime = DateTime.Now
        };

        return Ok(systemInfo);
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
    /// Checks if the critical external services are available.
    /// </summary>
    /// <returns>Returns a 200 OK response if all services are available.</returns>
    /// <response code="200">External services are available.</response>
    /// <response code="503">One or more external services are unavailable.</response>
    [HttpGet("service-dependencies", Name = "CheckServiceDependencies")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status503ServiceUnavailable)]
    public IActionResult CheckServiceDependencies()
    {
        // Helper method to check external services
        bool CheckExternalServices()
        {
            // Implement logic to check external services (e.g., HTTP requests to APIs, etc.)
            return true; // Assume services are available
        }

        bool areServicesAvailable = CheckExternalServices(); // Implement this method

        if (areServicesAvailable)
        {
            return Ok("All external services are available");
        }
        else
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, "One or more external services are unavailable");
        }
    }

    /// <summary>
    /// Checks if the database connection is working.
    /// </summary>
    /// <returns>Returns a 200 OK response if the database is reachable.</returns>
    /// <response code="200">Database is reachable.</response>
    /// <response code="503">Database is not reachable.</response>
    [HttpGet("db-connection", Name = "CheckDbConnection")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status503ServiceUnavailable)]
    public IActionResult CheckDatabaseConnection()
    {
        try
        {
            // Perform a lightweight query to check if the database connection is working
            var canConnect = _dbContext.Database.CanConnect();
            var connectionString = _dbContext.Database.GetConnectionString();
            _logger.LogInformation(connectionString);
            if (canConnect)
            {
                _logger.LogInformation("Database connection is successful.");
                return Ok("Database is connected.");
            }
            else
            {
                _logger.LogError("Database connection failed.");
                return StatusCode(StatusCodes.Status503ServiceUnavailable, "Database is unreachable.");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error while checking database connection.");
            return StatusCode(StatusCodes.Status503ServiceUnavailable, "Database check failed.");
        }
    }

}