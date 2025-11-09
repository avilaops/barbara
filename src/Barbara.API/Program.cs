using Barbara.Infrastructure.Data;
using Barbara.Infrastructure.Repositories;
using Barbara.Domain.Entities;
using MongoDB.Driver;
using DotNetEnv;

var builder = WebApplication.CreateBuilder(args);

// Carregar variáveis de ambiente do .env
if (File.Exists(".env"))
{
    Env.Load();
}

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// MongoDB Configuration
var mongoUri = Environment.GetEnvironmentVariable("MONGODB_URI") 
    ?? builder.Configuration.GetConnectionString("MongoDB")
    ?? throw new InvalidOperationException("MongoDB connection string not found. Set MONGODB_URI in .env file.");

var mongoClient = new MongoClient(mongoUri);
var mongoDatabase = mongoClient.GetDatabase("barbara");

// Register MongoDB Context
builder.Services.AddSingleton<IMongoDatabase>(mongoDatabase);
builder.Services.AddSingleton(new MongoDbContext(mongoUri, "barbara"));

// Register Repositories
builder.Services.AddScoped<IRepository<Cliente>>(sp => 
    new MongoRepository<Cliente>(sp.GetRequiredService<IMongoDatabase>(), "clientes"));
builder.Services.AddScoped<IRepository<Produto>>(sp => 
 new MongoRepository<Produto>(sp.GetRequiredService<IMongoDatabase>(), "produtos"));
builder.Services.AddScoped<IRepository<Categoria>>(sp => 
    new MongoRepository<Categoria>(sp.GetRequiredService<IMongoDatabase>(), "categorias"));
builder.Services.AddScoped<IRepository<Pedido>>(sp => 
    new MongoRepository<Pedido>(sp.GetRequiredService<IMongoDatabase>(), "pedidos"));
builder.Services.AddScoped<IRepository<Configuracao>>(sp => 
    new MongoRepository<Configuracao>(sp.GetRequiredService<IMongoDatabase>(), "configuracoes"));

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
         .AllowAnyMethod()
            .AllowAnyHeader()
      .WithExposedHeaders("X-Total-Count", "X-Page", "X-Page-Size");
    });
});

var app = builder.Build();

// NOTA: Criação de índices desabilitada temporariamente (executar manualmente se necessário)
// Os índices serão criados automaticamente pelo MongoDB Atlas quando necessário
/*
// Create MongoDB indexes on startup
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<MongoDbContext>();
    await context.CreateIndexesAsync();
}
*/

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
 app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.MapGet("/health", () => new {
    status = "healthy",
    database = "mongodb",
    timestamp = DateTime.UtcNow
})
.WithName("HealthCheck")
.WithOpenApi();

app.Run();
