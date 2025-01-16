using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public class UnitOfWork : IUnitOfWork, IDisposable
{
    private readonly DietiDeals24DbContext _context;
    private IDbContextTransaction _transaction;
    private bool _disposed = false;

    private readonly IRepository<User, Guid> _userRepository;
    private readonly IRepository<Vendor, Guid> _vendorRepository;
    public UnitOfWork(DietiDeals24DbContext context,
        IRepository<User, Guid> userRepository,
        IRepository<Vendor, Guid> vendorRepository)
    {
        this._context = context;
        _userRepository = userRepository;
        _vendorRepository = vendorRepository;
    }

    public IRepository<User, Guid> UserRepository { get => _userRepository; }
    public IRepository<Vendor, Guid> VendorRepository { get => _vendorRepository; }
    
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