using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class CategoryService: ICategoryService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<CategoryService> _logger;

    public CategoryService(IUnitOfWork unitOfWork, ILogger<CategoryService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<Category> GetCategoryByIdAsync(AuctionCategory auctionCategory)
    {
        _logger.LogError($"[SERVICE] Getting category: {auctionCategory}.");

        try
        {
            return await _unitOfWork.CategoryRepository
                .Get(category => category.Name.Equals(category.Name))
                .FirstOrDefaultAsync() ?? throw new InvalidOperationException($"Category {auctionCategory} not found.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting category {auctionCategory} failed: {ex.Message}");
            throw new Exception($"[SERVICE] Getting category {auctionCategory} failed.", ex);
        }
    }

    public async Task<IEnumerable<Category>> GetAllCategoriesAsync(string? predicate = null, params object[] parameters)
    {
        _logger.LogError("[SERVICE] Getting all categories.");

        try
        {
            return await _unitOfWork.CategoryRepository
                .Get(predicate, parameters)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[SERVICE] Getting all categories failed: {ex.Message}");
            throw new Exception("[SERVICE] Getting all categories failed.", ex);
        }
    }
}