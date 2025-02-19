using DietiDeals24.RestApi.Workers;
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

    [HttpGet("get-auctions", Name = "GetAuctions")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetAuctions(int pageNumber = 1, int pageSize = 5)
    {
        try
        {
            _logger.LogInformation("[CONTROLLER] Getting all auctions");
            var result = await _auctionWorker.GetHomePageAuctions(pageNumber, pageSize);

            if (result.Results.Any()) return Ok(result);
            return NotFound();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get all the auctions. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
}