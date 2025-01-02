using System.Threading.Tasks;

namespace DietiDeals24.DataAccessLayer.Services;

public interface ICheckService
{
    Task<bool> CheckDatabaseConnection();
}