using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IVendorService
{
    public Task<Vendor> GetVendorByIdAsync(Guid vendorId);
    public Task<IEnumerable<Vendor>> GetAllVendorsAsync(string? predicate = null, params object[] parameters);
    public Task<Vendor> CreateVendorAsync(CreateVendorDTO vendorDto);
    public Task AddSuccessfulAuctionToVendorAsync(Guid vendorId);
    public Task<Vendor> UpdateVendorAsync(UpdateVendorDTO vendorDto);
}