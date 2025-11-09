using MongoDB.Driver;
using MongoDB.Bson;
using System.Linq.Expressions;

namespace Barbara.Infrastructure.Repositories;

public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(Guid id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T> AddAsync(T entity);
    Task UpdateAsync(Guid id, T entity);
    Task DeleteAsync(Guid id);
}

public class MongoRepository<T> : IRepository<T> where T : class
{
 private readonly IMongoCollection<T> _collection;

  public MongoRepository(IMongoDatabase database, string collectionName)
    {
        _collection = database.GetCollection<T>(collectionName);
    }

 public async Task<T?> GetByIdAsync(Guid id)
    {
      var filter = Builders<T>.Filter.Eq("_id", id.ToString());
        return await _collection.Find(filter).FirstOrDefaultAsync();
    }

    public async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _collection.Find(_ => true).ToListAsync();
    }

    public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _collection.Find(predicate).ToListAsync();
    }

    public async Task<T> AddAsync(T entity)
    {
     await _collection.InsertOneAsync(entity);
 return entity;
    }

    public async Task UpdateAsync(Guid id, T entity)
    {
   var filter = Builders<T>.Filter.Eq("_id", id.ToString());
 await _collection.ReplaceOneAsync(filter, entity);
    }

    public async Task DeleteAsync(Guid id)
    {
        var filter = Builders<T>.Filter.Eq("_id", id.ToString());
        await _collection.DeleteOneAsync(filter);
    }
}
