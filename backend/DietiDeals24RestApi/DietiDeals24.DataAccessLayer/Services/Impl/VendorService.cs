using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class VendorService: IVendorService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<VendorService> _logger;

    public VendorService(IUnitOfWork unitOfWork, ILogger<VendorService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<Vendor> GetVendorByIdAsync(Guid vendorId)
    {
        _logger.LogError($"[SERVICE] Getting vendor for id: {vendorId}.");

        try
        {
            return await _unitOfWork.VendorRepository
                .Get(vendor => vendor.Id == vendorId)
                .FirstOrDefaultAsync() ?? throw new InvalidOperationException($"Vendor with id {vendorId} not found.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting vendor for id {vendorId} failed: {ex.Message}");
            throw new Exception($"[SERVICE] Getting vendor for id {vendorId} failed.", ex);
        }
    }

    public async Task<IEnumerable<Vendor>> GetAllVendorsAsync(string? predicate = null, params object[] parameters)
    {
        _logger.LogError("[SERVICE] Getting all vendors.");

        try
        {
            return await _unitOfWork.VendorRepository
                .Get(predicate, parameters)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting all vendors failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting all vendors failed.", ex);
        }
    }
}