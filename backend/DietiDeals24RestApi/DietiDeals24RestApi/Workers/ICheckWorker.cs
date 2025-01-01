using DietiDeals24RestApi.Models;

namespace DietiDeals24RestApi.Workers;

public interface ICheckWorker
{
    Task<string?> GetEnvironmentValue();

    Task<SystemInfoDTO> GetSystemInfos();
    
    Task<Boolean> CheckDatabaseConnection();
    
}