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
    public async Task<IActionResult> GetAuctionById(Guid id)
    {
        _logger.LogInformation("[CONTROLLER] Getting auction by id: {id}", id);
        var result = await _auctionWorker.GetAuctionById(id);
        if (result == null) return NotFound();
        return Ok(result);
    }
}