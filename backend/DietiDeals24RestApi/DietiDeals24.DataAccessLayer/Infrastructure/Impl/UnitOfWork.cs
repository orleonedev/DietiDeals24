using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;
using System.Threading.Tasks;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public class UnitOfWork : IUnitOfWork, IDisposable
{
    private readonly DietiDeals24DbContext _context;
    private IDbContextTransaction _transaction;
    private bool _disposed = false;

    // private readonly IRepository<Assets, int> assetsRepository;
    // private readonly IRepository<ProductAccessoriesShape, object[]> productAccessoriesShapeRepository;
    public UnitOfWork(DietiDeals24DbContext context)
    {
        this._context = context;
    }

    // public IRepository<Assets, int> AssetsRepository { get => assetsRepository; }
    // public IRepository<ProductAccessoriesShape, object[]> ProductAccessoriesShapeRepository { get => productAccessoriesShapeRepository; }

    public IExecutionStrategy CreateExecutionStrategy()
    {
        return _context.Database.CreateExecutionStrategy();
    }
    public void BeginTransaction()
    {
        _transaction ??= _context.Database.BeginTransaction();
    }

    public void Commit()
    {
        _transaction.Commit();
        _transaction = null;
    }

    public bool IsNullTransaction()
    {
        return _transaction == null;
    }

    public void Rollback()
    {
        _transaction.Rollback();
    }

    public async Task<int> Save()
    {
        return await _context.SaveChangesAsync(true);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!_disposed && disposing)
            _context.Dispose();

        _disposed = true;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
}