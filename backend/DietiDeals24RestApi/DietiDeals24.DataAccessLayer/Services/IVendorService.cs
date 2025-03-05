using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IVendorService
{
    public Task<Vendor> GetVendorByIdAsync(Guid vendorId);
    public Task<IEnumerable<Vendor>> GetAllVendorsAsync(string? predicate = null, params object[] parameters);
}