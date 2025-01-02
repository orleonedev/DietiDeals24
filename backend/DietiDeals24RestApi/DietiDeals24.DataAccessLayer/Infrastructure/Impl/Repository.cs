using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Linq.Expressions;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public class Repository<TEntity,TKey> : IRepository<TEntity,TKey> where TEntity : class
{
    private readonly DbSet<TEntity> _dbSet;
    private readonly DietiDeals24DbContext _context;

    public Repository(DietiDeals24DbContext context)
    {
        _context = context;
        _dbSet = context.Set<TEntity>();
    }

    public Task Add(TEntity entity)
    {
        if (entity == null)
            throw new ArgumentNullException(nameof(entity), "entity Paramenter cannot be null");

        return AddInternalAsync(entity);
    }
    private async Task AddInternalAsync(TEntity entity)
    {
        await _dbSet.AddAsync(entity).ConfigureAwait(false);
    }
    // public async Task BulkInsert(IList<TEntity> entities, BulkConfig bulkConfig = null)
    // {
    //     await _context.BulkInsertAsync<TEntity>(entities, bulkConfig);
    // }
    //
    // public async Task BulkDelete(IList<TEntity> entities, BulkConfig bulkConfig = null)
    // {
    //     await _context.BulkDeleteAsync<TEntity>(entities, bulkConfig);
    // }
    //
    // public async Task BulkInsertOrUpdate(IList<TEntity> entities, BulkConfig bulkConfig = null)
    // {
    //     await _context.BulkInsertOrUpdateAsync<TEntity>(entities, bulkConfig);
    // }
    //
    // public async Task BulkInsertOrUpdateOrDelete(IList<TEntity> entities, BulkConfig bulkConfig = null)
    // {
    //     await _context.BulkInsertOrUpdateOrDeleteAsync<TEntity>(entities, bulkConfig);
    // }

    public Task AddRange(IEnumerable<TEntity> entities)
    {
        if (entities == null)
            throw new ArgumentNullException(nameof(entities), "Entities Paramenter cannot be null");

        return AddRangeInternalAsync(entities);
    }
    private async Task AddRangeInternalAsync(IEnumerable<TEntity> entities)
    {
        await _dbSet.AddRangeAsync(entities).ConfigureAwait(false);
    }

    public Task Delete(Expression<Func<TEntity, bool>> predicate)
    {
        IQueryable<TEntity> records = from x in _dbSet.Where<TEntity>(predicate) select x;
        foreach (TEntity record in records)
            _dbSet.Remove(record);

        return Task.CompletedTask;
    }

    public async Task Delete(TKey id)
    {
        var entity = await _dbSet.FindAsync(id);
        if (entity != null)
            _dbSet.Remove(entity);
    }

    public IQueryable<TEntity> Get(Expression<Func<TEntity, bool>> predicate)
    {
        _dbSet.AsNoTracking();
        if (predicate != null)
            return _dbSet.Where<TEntity>(predicate);

        return _dbSet;
    }

    public IQueryable<TEntity> Get(string predicate, params object[] obj)
    {
        _dbSet.AsNoTracking();
        if (!string.IsNullOrEmpty(predicate))
            return _dbSet.Where(predicate, obj);

        return _dbSet;
    }

    public async Task<TEntity> Get(TKey id)
    {
        _dbSet.AsNoTracking();
        return await _dbSet.FindAsync(id);
    }

    public Task RemoveRange(IEnumerable<TEntity> entities)
    {
        if (entities == null)
            throw new ArgumentNullException(nameof(entities), "Entities Paramenter cannot be null");

        _dbSet.RemoveRange(entities);

        return Task.CompletedTask;
    }

    public Task Update(TEntity entity)
    {
        if (entity == null)
            throw new ArgumentNullException(nameof(entity), "entity Paramenter cannot be null");

        _dbSet.Attach(entity);
        _context.Entry<TEntity>(entity).State = EntityState.Modified;

        return Task.CompletedTask;
    }
}