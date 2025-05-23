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

    [HttpGet("test-get-all-auctions", Name = "TestGetAllAuctions")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetAllAuctions()
    {
        _logger.LogInformation("[CONTROLLER] Getting all auctions");

        try
        {
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

    [HttpPost("get-paginated-auctions", Name = "GetPaginatedAuctions")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetPaginatedAuctions([FromBody] AuctionFiltersDTO filters)
    {
        _logger.LogInformation("[CONTROLLER] Getting paginated auctions");

        try
        {
            var result = await _auctionWorker.GetPaginatedAuctions(filters);

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get paginated auctions. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
    
    [HttpGet("get-detailed-auction-by-id", Name = "GetDetailedAuctionById")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetDetailedAuctionById([FromQuery] Guid id)
    {
        _logger.LogInformation("[CONTROLLER] Getting all detailed auctions");

        try
        {
            var result = await _auctionWorker.GetDetailedAuctionById(id);
            
            if(result != null) return Ok(result);
            return NotFound();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get the auction. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("create-auction", Name = "CreateAuction")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateAuction([FromBody] CreateAuctionDTO auction)
    {
        _logger.LogInformation("[CONTROLLER] Creating new auction");

        try
        {
            var result = await _auctionWorker.CreateAuction(auction);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get create new auction. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("on-auction-end-time-reached", Name = "OnAuctionEndTimeReached")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> OnAuctionEndTimeReached([FromBody] Guid auctionId)
    {
        _logger.LogInformation($"[CONTROLLER] OnAuctionEndTimeReached for auction: {auctionId}");
        try
        {
            await _auctionWorker.OnAuctionEndTimeReached(auctionId);
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] On Auction {auctionId} end time reached failed: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
}