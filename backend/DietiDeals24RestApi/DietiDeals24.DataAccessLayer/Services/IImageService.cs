using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mime;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IImageService
{
    public Task<Dictionary<Guid, List<string>>> GetImagesUrlsForAuctionAsync(List<Guid> auctionIds);
    public Task<List<string>> GetImagesUrlsForAuctionAsync(Guid auctionId);
    public Task<Dictionary<Guid, string>> AddImagesUrlsForAuctionAsync(Guid auctionId, List<Guid> imagesId);
}