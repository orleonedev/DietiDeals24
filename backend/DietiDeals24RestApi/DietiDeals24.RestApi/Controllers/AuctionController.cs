using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.RestApi.Workers;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.AspNetCore.Mvc;

namespace DietiDeals24.RestApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuctionController : ControllerBase
{
    private readonly ILogger<AuctionController> _logger;
    private readonly IAuctionWorker _auctionWorker;

    public AuctionController(ILogger<AuctionController> logger, IAuctionWorker auctionWorker)
    {
        _logger = logger;
        _auctionWorker = auctionWorker;
    }

    [HttpGet("get-auction-by-id", Name = "GetAuctionById")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetAuctionById(Guid id)
    {
        try
        {
            _logger.LogInformation("[CONTROLLER] Getting auction by id: {id}", id);
            var result = await _auctionWorker.GetAuctionById(id);
            if (result == null) return NotFound();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get auction by id: {id}. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("get-all-auctions", Name = "GetAllAuctions")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetAllAuctions()
    {
        try
        {
            _logger.LogInformation("[CONTROLLER] Getting all auctions");
            var result = await _auctionWorker.GetAllAuctions();

            if (result.Any()) return Ok(result);
            return NotFound();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get all the auctions. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("get-paginated-auctions", Name = "GetPaginatedAuctions")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetPaginatedAuctions([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 5, 
        [FromQuery] AuctionFilters filters = null)
    {
        try
        {
            _logger.LogInformation("[CONTROLLER] Getting paginated auctions");
            var result = await _auctionWorker.GetPaginatedAuctions(pageNumber, pageSize, filters);

            if (result.Results.Any()) return Ok(result);
            return NotFound();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get paginated auctions. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("create-auction", Name = "CreateAuction")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateAuction([FromBody] CreateAuctionDTO auction)
    {
        try
        {
            _logger.LogInformation("[CONTROLLER] Creating new auction");
            
            var result = await _auctionWorker.CreateAuction(auction);

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get create new auction. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
}