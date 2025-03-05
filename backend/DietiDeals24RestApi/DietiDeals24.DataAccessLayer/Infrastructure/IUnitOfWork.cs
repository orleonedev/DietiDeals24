using System;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore.Storage;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public interface IUnitOfWork
{
    public IRepository<User, Guid> UserRepository { get; }
    public IRepository<Vendor, Guid> VendorRepository { get; }
    public IRepository<Auction, Guid> AuctionRepository { get; }
    public IRepository<Bid, Guid> BidRepository { get; }
    public IRepository<AuctionImage, Guid> AuctionImageRepository { get; }
    public IRepository<Notification, Guid> NotificationRepository { get; }
    public IRepository<UserPushToken, Guid> UserPushTokenRepository { get; }
    Task<int> Save();
    IExecutionStrategy CreateExecutionStrategy();
    void BeginTransaction();
    bool IsNullTransaction();
    void Commit();
    void Rollback();
}
