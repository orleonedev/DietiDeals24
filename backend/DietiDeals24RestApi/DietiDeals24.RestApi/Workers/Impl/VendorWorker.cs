using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;

namespace DietiDeals24.RestApi.Workers.Impl;

public class VendorWorker: IVendorWorker
{
    private readonly ILogger<VendorWorker> _logger;
    private readonly IVendorService _vendorService;
    private readonly IAuthenticationService _authenticationService;

    public VendorWorker(ILogger<VendorWorker> logger, IVendorService vendorService, 
        IAuthenticationService authenticationService)
    {
        _logger = logger;
        _vendorService = vendorService;
        _authenticationService = authenticationService;
    }

    public async Task<DetailedVendorDTO> CreateVendorAsync(CreateVendorDTO vendorDto)
    {
        _logger.LogInformation($"[WORKER] Creating new vendor for UserId: {vendorDto.UserId}.");

        try
        {
            var vendor = await _vendorService.CreateVendorAsync(vendorDto);

            if (vendor != null)
            {
                if (await _authenticationService.UpdateVendorStatusAsync(vendor.Id, vendor.User.Username))
                {
                    return new DetailedVendorDTO
                    {
                        Id = vendor.Id,
                        Name = vendor.User.Fullname,
                        Username = vendor.User.Username,
                        Email = vendor.User.Email,
                        SuccessfulAuctions = vendor.SuccessfulAuctions,
                        JoinedSince = vendor.StartingDate,
                        GeoLocation = vendor.GeoLocation,
                        WebSiteUrl = vendor.WebSiteUrl,
                        ShortBio = vendor.ShortBio
                    };
                }
                
                throw new Exception("[WORKER] Error creating new vendor: updating vendor status cognito failed.");
            }
            
            throw new Exception("[WORKER] Error creating new vendor: vendor not added correctly.");
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
                GeoLocation = vendor.GeoLocation,
                WebSiteUrl = vendor.WebSiteUrl,
                ShortBio = vendor.ShortBio
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Failed to get vendor details for id: {vendorId}. Exception occurred: {ex.Message}");
            throw new Exception($"[WORKER] Failed to get vendor details for id: {vendorId}. Exception occurred: {ex.Message}", ex);
        }
    }

    public async Task<DetailedVendorDTO> UpdateVendorAsync(UpdateVendorDTO vendorDto)
    {
        try
        {
            var vendor = await _vendorService.UpdateVendorAsync(vendorDto);

            var detailedVendor = new DetailedVendorDTO
            {
                Id = vendor.Id,
                Name = vendor.User.Fullname,
                Username = vendor.User.Username,
                Email = vendor.User.Email,
                SuccessfulAuctions = vendor.SuccessfulAuctions,
                JoinedSince = vendor.StartingDate,
                GeoLocation = vendor.GeoLocation,
                WebSiteUrl = vendor.WebSiteUrl,
                ShortBio = vendor.ShortBio
            };

            return detailedVendor;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Failed to update vendor with id: {vendorDto.VendorId}. Exception occurred: {ex.Message}");
            throw new Exception($"[WORKER] Failed to to update vendor with id: {vendorDto.VendorId}. Exception occurred: {ex.Message}", ex);
        }
    }
}