using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.RestApi.Workers;

public interface IVendorWorker
{
    public Task<DetailedVendorDTO> CreateVendorAsync(CreateVendorDTO vendor);
    public Task<DetailedVendorDTO> GetVendorByIdAsync(Guid vendorId);
    public Task<DetailedVendorDTO> UpdateVendorAsync(UpdateVendorDTO vendor);
}