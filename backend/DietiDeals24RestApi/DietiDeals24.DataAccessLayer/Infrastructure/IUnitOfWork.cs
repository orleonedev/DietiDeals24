using System;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore.Storage;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public interface IUnitOfWork
{
    public IRepository<User, Guid> UserRepository { get; }
    public IRepository<Vendor, Guid> VendorRepository { get; }
    Task<int> Save();
    IExecutionStrategy CreateExecutionStrategy();
    void BeginTransaction();
    bool IsNullTransaction();
    void Commit();
    void Rollback();
}
