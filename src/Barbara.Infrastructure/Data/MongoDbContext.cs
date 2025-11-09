using Barbara.Domain.Entities;
using MongoDB.Driver;
using DotNetEnv;

namespace Barbara.Infrastructure.Data;

public class MongoDbContext
{
    private readonly IMongoDatabase _database;

    public MongoDbContext(string connectionString, string databaseName = "barbara")
    {
  // Carregar variáveis de ambiente
        if (File.Exists(Path.Combine(Directory.GetCurrentDirectory(), ".env")))
  {
            Env.Load();
        }

        // Usar connection string do parâmetro ou variável de ambiente
     var mongoUri = connectionString ?? Environment.GetEnvironmentVariable("MONGODB_URI");
        
  if (string.IsNullOrEmpty(mongoUri))
        {
          throw new InvalidOperationException("MongoDB connection string not found. Set MONGODB_URI in .env file or pass as parameter.");
        }

    var client = new MongoClient(mongoUri);
        _database = client.GetDatabase(databaseName);
    }

 // Collections
  public IMongoCollection<Cliente> Clientes => _database.GetCollection<Cliente>("clientes");
    public IMongoCollection<Produto> Produtos => _database.GetCollection<Produto>("produtos");
    public IMongoCollection<Categoria> Categorias => _database.GetCollection<Categoria>("categorias");
    public IMongoCollection<Pedido> Pedidos => _database.GetCollection<Pedido>("pedidos");
    public IMongoCollection<Configuracao> Configuracoes => _database.GetCollection<Configuracao>("configuracoes");

    // Método helper para criar índices
    public async Task CreateIndexesAsync()
  {
 // Índices de Cliente
        var clienteIndexKeys = Builders<Cliente>.IndexKeys
   .Ascending(c => c.Email);
    var clienteIndexModel = new CreateIndexModel<Cliente>(clienteIndexKeys, 
            new CreateIndexOptions { Unique = true });
        await Clientes.Indexes.CreateOneAsync(clienteIndexModel);

   var cpfIndexKeys = Builders<Cliente>.IndexKeys
            .Ascending(c => c.CPF);
        var cpfIndexModel = new CreateIndexModel<Cliente>(cpfIndexKeys,
 new CreateIndexOptions { Unique = true });
        await Clientes.Indexes.CreateOneAsync(cpfIndexModel);

        // Índices de Produto
     var skuIndexKeys = Builders<Produto>.IndexKeys
            .Ascending(p => p.SKU);
      var skuIndexModel = new CreateIndexModel<Produto>(skuIndexKeys,
          new CreateIndexOptions { Unique = true });
        await Produtos.Indexes.CreateOneAsync(skuIndexModel);

        var produtoNomeIndexKeys = Builders<Produto>.IndexKeys
    .Text(p => p.Nome)
            .Text(p => p.Descricao);
      var produtoNomeIndexModel = new CreateIndexModel<Produto>(produtoNomeIndexKeys);
        await Produtos.Indexes.CreateOneAsync(produtoNomeIndexModel);

        // Índices de Pedido
        var pedidoNumeroIndexKeys = Builders<Pedido>.IndexKeys
  .Ascending(p => p.NumeroPedido);
        var pedidoNumeroIndexModel = new CreateIndexModel<Pedido>(pedidoNumeroIndexKeys,
   new CreateIndexOptions { Unique = true });
        await Pedidos.Indexes.CreateOneAsync(pedidoNumeroIndexModel);

        var pedidoClienteIndexKeys = Builders<Pedido>.IndexKeys
            .Ascending(p => p.ClienteId)
     .Descending(p => p.DataPedido);
    var pedidoClienteIndexModel = new CreateIndexModel<Pedido>(pedidoClienteIndexKeys);
        await Pedidos.Indexes.CreateOneAsync(pedidoClienteIndexModel);

        // Índices de Configuração
        var configChaveIndexKeys = Builders<Configuracao>.IndexKeys
            .Ascending(c => c.Chave);
        var configChaveIndexModel = new CreateIndexModel<Configuracao>(configChaveIndexKeys,
     new CreateIndexOptions { Unique = true });
        await Configuracoes.Indexes.CreateOneAsync(configChaveIndexModel);
  }
}
