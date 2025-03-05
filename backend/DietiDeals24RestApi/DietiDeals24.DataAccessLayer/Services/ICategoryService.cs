using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Services;

public interface ICategoryService
{
    public Task<Category> GetCategoryByIdAsync(AuctionCategory category);
    public Task<IEnumerable<Category>> GetAllCategoriesAsync(string? predicate = null, params object[] parameters);
}