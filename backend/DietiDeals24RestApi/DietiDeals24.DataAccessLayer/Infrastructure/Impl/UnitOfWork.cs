using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public class UnitOfWork : IUnitOfWork, IDisposable
{
    private readonly DietiDeals24DbContext _context;
    private IDbContextTransaction? _transaction;
    private bool _disposed = false;

    private readonly IRepository<User, Guid> _userRepository;
    private readonly IRepository<Vendor, Guid> _vendorRepository;
    private IRepository<Auction, Guid> _auctionRepository;
    private IRepository<Bid, Guid> _bidRepository;
    private IRepository<AuctionImage, Guid> _auctionImageRepository;
    private IRepository<Notification, Guid> _notificationRepository;
    private IRepository<UserPushToken, Guid> _userPushTokenRepository;

    public UnitOfWork(DietiDeals24DbContext context,
        IRepository<User, Guid> userRepository,
        IRepository<Vendor, Guid> vendorRepository,
        IRepository<Auction, Guid> auctionRepository, 
        IRepository<Bid, Guid> bidRepository, 
        IRepository<AuctionImage, Guid> auctionImageRepository, 
        IRepository<Notification, Guid> notificationRepository, 
        IRepository<UserPushToken, Guid> userPushTokenRepository)
    {
        _context = context;
        _userRepository = userRepository;
        _vendorRepository = vendorRepository;
        _auctionRepository = auctionRepository;
        _bidRepository = bidRepository;
        _auctionImageRepository = auctionImageRepository;
        _notificationRepository = notificationRepository;
        _userPushTokenRepository = userPushTokenRepository;
    }

    public IRepository<User, Guid> UserRepository => _userRepository;
    public IRepository<Vendor, Guid> VendorRepository => _vendorRepository;
    public IRepository<Auction, Guid> AuctionRepository => _auctionRepository;

    public IRepository<Bid, Guid> BidRepository => _bidRepository;

    public IRepository<AuctionImage, Guid> AuctionImageRepository => _auctionImageRepository;

    public IRepository<Notification, Guid> NotificationRepository => _notificationRepository;

    public IRepository<UserPushToken, Guid> UserPushTokenRepository => _userPushTokenRepository;

    public IExecutionStrategy CreateExecutionStrategy()
    {
        return _context.Database.CreateExecutionStrategy();
    }
    public void BeginTransaction()
    {
        _transaction = _context.Database.BeginTransaction();
    }

    public void Commit()
    {
        _transaction?.Commit();
        _transaction = null;
    }

    public bool IsNullTransaction()
    {
        return _transaction == null;
    }

    public void Rollback()
    {
        _transaction?.Rollback();
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