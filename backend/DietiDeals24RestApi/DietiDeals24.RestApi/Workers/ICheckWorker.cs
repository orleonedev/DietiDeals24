using DietiDeals24.RestApi.Models;

namespace DietiDeals24.RestApi.Workers;

public interface ICheckWorker
{
    Task<string?> GetEnvironmentValue();

    Task<SystemInfoDTO> GetSystemInfos();
    
    Task<bool> CheckDatabaseConnection();
    
}