using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;

namespace DietiDeals24.RestApi.Workers.Impl;

public class VendorWorker: IVendorWorker
{
    private readonly ILogger<VendorWorker> _logger;
    private readonly IVendorService _vendorService;

    public VendorWorker(ILogger<VendorWorker> logger, IVendorService vendorService)
    {
        _logger = logger;
        _vendorService = vendorService;
    }

    public async Task<DetailedVendorDTO> CreateVendorAsync(CreateVendorDTO vendorDto)
    {
        _logger.LogInformation($"[WORKER] Creating new vendor for UserId: {vendorDto.UserId}.");

        try
        {
            var vendor = await _vendorService.CreateVendorAsync(vendorDto);

            return new DetailedVendorDTO
            {
                Id = vendor.Id,
                Name = vendor.User.Fullname,
                Username = vendor.User.Username, // to be fixed
                Email = vendor.User.Email, //to be fixed
                SuccessfulAuctions = vendor.SuccessfulAuctions,
                JoinedSince = vendor.StartingDate,
                Geolocation = vendor.GeoLocation,
                WebSiteUrl = vendor.WebSiteUrl
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Failed to create new vendor for UserId: {vendorDto.UserId}. Exception occurred: {ex.Message}");
            throw new Exception($"[WORKER] Failed to create new vendor for UserId: {vendorDto.UserId}. Exception occurred: {ex.Message}", ex);
        }
    }

    public async Task<DetailedVendorDTO> GetVendorByIdAsync(Guid vendorId)
    {
        _logger.LogInformation($"[WORKER] Getting vendor details for id: {vendorId}.");

        try
        {
            var vendor = await _vendorService.GetVendorByIdAsync(vendorId);

            return new DetailedVendorDTO
            {
                Id = vendor.Id,
                Name = vendor.User.Fullname,
                Username = vendor.User.Username,
                Email = vendor.User.Email,
                SuccessfulAuctions = vendor.SuccessfulAuctions,
                JoinedSince = vendor.StartingDate,
                Geolocation = vendor.GeoLocation,
                WebSiteUrl = vendor.WebSiteUrl
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Failed to get vendor details for id: {vendorId}. Exception occurred: {ex.Message}");
            throw new Exception($"[WORKER] Failed to get vendor details for id: {vendorId}. Exception occurred: {ex.Message}", ex);
        }
    }
}