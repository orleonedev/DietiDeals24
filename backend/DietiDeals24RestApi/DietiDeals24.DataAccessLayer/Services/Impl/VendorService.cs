using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
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
                .Select(vendor => new Vendor
                {
                    Id = vendor.Id,
                    UserId = vendor.UserId,
                    GeoLocation = vendor.GeoLocation,
                    WebSiteUrl = vendor.WebSiteUrl,
                    ShortBio = vendor.ShortBio,
                    StartingDate = vendor.StartingDate,
                    SuccessfulAuctions = vendor.SuccessfulAuctions,
                    User = vendor.User
                })
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

    public async Task<Vendor> CreateVendorAsync(CreateVendorDTO vendorDto)
    {
        _logger.LogError($"[SERVICE] Creating new vendor for UserId: {vendorDto.UserId}.");

        try
        {
            var vendor = await _unitOfWork.VendorRepository
                .Get(vendor => vendor.UserId == vendorDto.UserId)
                .FirstOrDefaultAsync();

            if (vendor != null)
            {
                throw new InvalidOperationException($"Vendor with UserId {vendorDto.UserId} already exists.");
            }

            DateTime now = DateTime.Now;
            DateTime startingDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
            
            var newVendor = new Vendor
            {
                UserId = vendorDto.UserId,
                GeoLocation = vendorDto.GeoLocation,
                WebSiteUrl = vendorDto.WebSiteUrl,
                ShortBio = vendorDto.ShortBio,
                StartingDate = startingDate,
                SuccessfulAuctions = 0
            };
            
            var user = await _unitOfWork.UserRepository
                .Get(user => user.Id == vendorDto.UserId)
                .FirstOrDefaultAsync();

            user.Role = UserRole.Seller;
            
            _unitOfWork.BeginTransaction();
            await _unitOfWork.VendorRepository.Add(newVendor);
            await _unitOfWork.UserRepository.Update(user);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

            var resultVendor = await _unitOfWork.VendorRepository
                .Get(vendor => newVendor.Id == vendor.Id)
                .Select(vendor => new Vendor
                {
                    Id = vendor.Id,
                    UserId = vendor.UserId,
                    GeoLocation = vendor.GeoLocation,
                    WebSiteUrl = vendor.WebSiteUrl,
                    ShortBio = vendor.ShortBio,
                    StartingDate = vendor.StartingDate,
                    SuccessfulAuctions = vendor.SuccessfulAuctions,
                    User = vendor.User
                })
                .FirstOrDefaultAsync();
            
            return resultVendor;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Failed to create new vendor for UserId: {vendorDto.UserId}. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Failed to create new vendor for UserId: {vendorDto.UserId}. Exception occurred: {ex.Message}", ex);
        }
    }

    public async Task AddSuccessfulAuctionToVendorAsync(Guid vendorId)
    {
        _logger.LogInformation($"[SERVICE] updating vendor successful auctions for vendorId: {vendorId}.");
        try
        {
            var vendor = await _unitOfWork.VendorRepository
                .Get(vendor => vendor.Id == vendorId)
                .FirstOrDefaultAsync();

            if (vendor == null)
            {
                _logger.LogError($"[SERVICE] Updating vendor successful auctions with id: {vendorId} failed. Vendor does not exist.");
                return;
            }

            vendor.SuccessfulAuctions++;
            _unitOfWork.BeginTransaction();
            await _unitOfWork.VendorRepository.Update(vendor);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Updating vendor successful auctions with id: {vendorId} failed. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Updating vendor successful auctions with id: {vendorId} failed. Exception occurred: {ex.Message}", ex);
        }
    }

    public async Task<Vendor> UpdateVendorAsync(UpdateVendorDTO vendorDto)
    {
        try
        {
            var vendor = await _unitOfWork.VendorRepository
                .Get(vendor => vendor.Id == vendorDto.VendorId)
                .Select(vendor => new Vendor
                {
                    Id = vendor.Id,
                    UserId = vendor.UserId,
                    GeoLocation = vendor.GeoLocation,
                    WebSiteUrl = vendor.WebSiteUrl,
                    ShortBio = vendor.ShortBio,
                    StartingDate = vendor.StartingDate,
                    SuccessfulAuctions = vendor.SuccessfulAuctions,
                    User = vendor.User
                })
                .FirstOrDefaultAsync();
            
            if (vendor == null)
            {
                throw new InvalidOperationException($"Vendor with UserId {vendorDto.VendorId} does not exists.");
            }

            var newVendor = new Vendor
            {
                Id = vendor.Id,
                UserId = vendor.UserId,
                GeoLocation = vendorDto.GeoLocation,
                WebSiteUrl = vendorDto.WebSiteUrl,
                ShortBio = vendorDto.ShortBio,
                StartingDate = vendor.StartingDate,
                SuccessfulAuctions = vendor.SuccessfulAuctions
            };
            
            _unitOfWork.BeginTransaction();
            await _unitOfWork.VendorRepository.Update(vendor);
            _unitOfWork.Commit();
            await _unitOfWork.Save();

            return newVendor;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Failed to update vendor with id: {vendorDto.VendorId}. Exception occurred: {ex.Message}");
            throw new Exception($"[SERVICE] Failed to update vendor with id: {vendorDto.VendorId}. Exception occurred: {ex.Message}", ex);
        }
    }
}