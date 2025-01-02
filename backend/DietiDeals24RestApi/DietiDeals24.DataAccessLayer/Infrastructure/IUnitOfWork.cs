using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore.Storage;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public interface IUnitOfWork
{
    // IRepository<Assets, int> AssetsRepository { get; }
    // IRepository<ProductAccessoriesShape, object[]> ProductAccessoriesShapeRepository { get; }
    Task<int> Save();
    IExecutionStrategy CreateExecutionStrategy();
    void BeginTransaction();
    bool IsNullTransaction();
    void Commit();
    void Rollback();
}
