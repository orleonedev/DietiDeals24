using System.Reflection;
using DietiDeals24RestApi.Models;

namespace DietiDeals24RestApi.Workers.Impl;

public class CheckWorker: ICheckWorker
{
    private readonly ApplicationDbContext _context;

    public CheckWorker(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<string?> GetEnvironmentValue()
    {
        var task = Task.Run(() => Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"));
        return await task;
    }

    public async Task<SystemInfoDTO> GetSystemInfos()
    {
        var systemInfo = new SystemInfoDTO
        {
            ApplicationVersion = Assembly.GetExecutingAssembly().GetName().Version?.ToString(),
            MachineName = Environment.MachineName,
            OSVersion = Environment.OSVersion.ToString(),
            CurrentDateTime = DateTime.Now
        };
        var task = Task.Run(() => systemInfo);
        return await task;
    }

    public async Task<bool> CheckDatabaseConnection()
    {
        var canConnect = await _context.Database.CanConnectAsync();
        return canConnect;
    }
}