using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.RestApi.Workers;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.AspNetCore.Mvc;

namespace DietiDeals24.RestApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VendorController : ControllerBase
{
    private readonly ILogger<VendorController> _logger;
    private readonly IVendorWorker _vendorWorker;

    public VendorController(ILogger<VendorController> logger, IVendorWorker vendorWorker)
    {
        _logger = logger;
        _vendorWorker = vendorWorker;
    }

    [HttpPost("become-a-vendor", Name = "BecomeAVendor")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> BecomeAVendor([FromBody] CreateVendorDTO vendor)
    {
        _logger.LogInformation($"[CONTROLLER] Creating new vendor for UserId: {vendor.UserId}.");
        
        try
        {
            var result = await _vendorWorker.CreateVendorAsync(vendor);

            if (result == null)
            {
                return NotFound();
            }
                
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get create new vendor for UserId: {vendor.UserId}. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
    
    [HttpPost("get-vendor-by-id", Name = "GetVendorById")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetVendorById([FromQuery] Guid vendorId)
    {
        _logger.LogInformation($"[CONTROLLER] Getting vendor details for id: {vendorId}.");
        
        try
        {
            var result = await _vendorWorker.GetVendorByIdAsync(vendorId);

            if (result == null)
            {
                return NotFound();
            }
                
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to get vendor details for id: {vendorId}. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("update-vendor", Name = "UpdateVendor")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateVendor([FromBody] UpdateVendorDTO vendor)
    {
        try
        {
            var result = await _vendorWorker.UpdateVendorAsync(vendor);

            if (result == null)
            {
                return NotFound();
            }
                
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[CONTROLLER] Failed to update vendor with id: {vendor.VendorId}. Exception occurred: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
}