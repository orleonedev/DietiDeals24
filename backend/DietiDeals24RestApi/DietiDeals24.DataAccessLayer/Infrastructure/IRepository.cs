using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Infrastructure;

public interface IRepository<TEntity, TKey> where TEntity : class
{
    Task Add(TEntity entity);
    // Task BulkInsert(IList<TEntity> entities, BulkConfig bulkConfig = null);
    // Task BulkDelete(IList<TEntity> entities, BulkConfig bulkConfig = null);
    // Task BulkInsertOrUpdate(IList<TEntity> entities, BulkConfig bulkConfig = null);
    // Task BulkInsertOrUpdateOrDelete(IList<TEntity> entities, BulkConfig bulkConfig = null);
    Task AddRange(IEnumerable<TEntity> entities);
    Task RemoveRange(IEnumerable<TEntity> entities);
    Task Update(TEntity entity);
    IQueryable<TEntity> Get(Expression<Func<TEntity, bool>> predicate);
    IQueryable<TEntity> Get(string predicate, params object[] obj);
    Task<TEntity> Get(TKey id);
    Task Delete(Expression<Func<TEntity, bool>> predicate);
    Task Delete(TKey id);
    public Task<int> CountAsync();
    public Task<int> CountAsync(Expression<Func<TEntity, bool>> predicate);
}