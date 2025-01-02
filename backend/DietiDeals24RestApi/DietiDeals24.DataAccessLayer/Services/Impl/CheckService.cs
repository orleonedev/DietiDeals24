using System.Data;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Infrastructure;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class CheckService : ICheckService
{
    
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<CheckService> _logger;
    private readonly DietiDeals24DbContext _context;

    public CheckService(IUnitOfWork unitOfWork, ILogger<CheckService> logger, DietiDeals24DbContext context)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
        _context = context;
    }

    public async Task<bool> CheckDatabaseConnection()
    {
        _logger.LogInformation("Checking database connection ON SERVICE DAL");
        var canConnect = await _context.Database.CanConnectAsync();
        return canConnect;
    }
    
}