using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.RestApi.Workers;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.AspNetCore.Mvc;

namespace DietiDeals24.RestApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BidController : ControllerBase
{
    private readonly ILogger<BidController> _logger;
    private readonly IBidWorker _bidWorker;

    public BidController(ILogger<BidController> logger, IBidWorker bidWorker)
    {
        _logger = logger;
        _bidWorker = bidWorker;
    }

    [HttpPost("create-bid", Name = "CreateBid")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> MakeBid([FromBody] CreateBidDTO bid)
    {
        _logger.LogInformation($"[CONTROLLER] Creating new bid for Auction: {bid.AuctionId}.");
        
        try
        {
            var result = await _bidWorker.CreateBidAsync(bid);

            if (result == null)
            {
                return BadRequest();
            }
                
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get create new bid for Auction: {bid.AuctionId}. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
}