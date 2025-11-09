# ?? MIGRAÇÃO PARA MONGODB - STATUS

## ? O QUE FOI FEITO

### 1. Infraestrutura MongoDB

? **Pacotes Instalados:**
- MongoDB.Driver 2.30.0
- MongoDB.Bson 2.30.0
- DotNetEnv 3.1.1

? **Arquivos Criados:**
- `src/Barbara.Infrastructure/Data/MongoDbContext.cs` - Context MongoDB com índices
- `src/Barbara.Infrastructure/Repositories/MongoRepository.cs` - Repositório genérico
- `.env` - Arquivo de configuração (precisa da URI do MongoDB)

? **Entidades Atualizadas:**
- `Cliente` - Atributos MongoDB + embedded documents
- `Endereco` - Convertido para embedded document

? **Configuração:**
- `Program.cs` - Migrado para MongoDB
- `appsettings.json` - Atualizado com connection string MongoDB
- `Barbara.Domain.csproj` - Adicionado MongoDB.Bson
- `Barbara.Infrastructure.csproj` - Removido EF Core, adicionado MongoDB
- `Barbara.API.csproj` - Removido EF Core Design, adicionado DotNetEnv

? **Limpeza:**
- Removida pasta `Migrations` (Entity Framework)
- Renomeado `BarbaraDbContext.cs` para `.old`

---

## ?? O QUE FALTA FAZER

### 2. Atualizar Controllers

Os controllers ainda estão usando `BarbaraDbContext` e `EntityFrameworkCore`. Precisam ser atualizados para usar `IRepository<T>`:

**Arquivos para atualizar:**
- `src/Barbara.API/Controllers/CarrinhoController.cs`
- `src/Barbara.API/Controllers/CategoriasController.cs`
- `src/Barbara.API/Controllers/ClientesController.cs`
- `src/Barbara.API/Controllers/PedidosController.cs`
- `src/Barbara.API/Controllers/ProdutosController.cs`

**Mudanças necessárias:**

```csharp
// ANTES (Entity Framework)
using Microsoft.EntityFrameworkCore;
using Barbara.Infrastructure.Data;

public class CategoriasController : ControllerBase
{
    private readonly BarbaraDbContext _context;
    
    public CategoriasController(BarbaraDbContext context)
    {
        _context = context;
    }
    
    [HttpGet]
  public async Task<ActionResult<IEnumerable<Categoria>>> GetCategorias()
    {
        return await _context.Categorias.ToListAsync();
    }
}
```

```csharp
// DEPOIS (MongoDB)
using Barbara.Infrastructure.Repositories;
using Barbara.Domain.Entities;

public class CategoriasController : ControllerBase
{
    private readonly IRepository<Categoria> _repository;
    
    public CategoriasController(IRepository<Categoria> repository)
    {
 _repository = repository;
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Categoria>>> GetCategorias()
    {
   return Ok(await _repository.GetAllAsync());
    }
 
    [HttpGet("{id}")]
    public async Task<ActionResult<Categoria>> GetCategoria(Guid id)
    {
        var categoria = await _repository.GetByIdAsync(id);
        if (categoria == null) return NotFound();
        return Ok(categoria);
    }
 
    [HttpPost]
    public async Task<ActionResult<Categoria>> PostCategoria(CategoriaDto dto)
  {
      var categoria = new Categoria
      {
          Nome = dto.Nome,
          Descricao = dto.Descricao,
     Ativa = dto.Ativa
        };
    
        await _repository.AddAsync(categoria);
        return CreatedAtAction(nameof(GetCategoria), new { id = categoria.Id }, categoria);
    }
    
    [HttpPut("{id}")]
    public async Task<IActionResult> PutCategoria(Guid id, CategoriaDto dto)
    {
        var categoria = await _repository.GetByIdAsync(id);
        if (categoria == null) return NotFound();
        
        categoria.Nome = dto.Nome;
        categoria.Descricao = dto.Descricao;
      categoria.Ativa = dto.Ativa;
   
        await _repository.UpdateAsync(id, categoria);
        return NoContent();
    }
    
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCategoria(Guid id)
    {
        var categoria = await _repository.GetByIdAsync(id);
   if (categoria == null) return NotFound();
  
        await _repository.DeleteAsync(id);
        return NoContent();
    }
}
```

---

### 3. Atualizar Entidades Restantes

Adicionar atributos MongoDB nas entidades:

**Arquivos para atualizar:**
- `src/Barbara.Domain/Entities/Produto.cs`
- `src/Barbara.Domain/Entities/Categoria.cs`
- `src/Barbara.Domain/Entities/Pedido.cs`
- `src/Barbara.Domain/Entities/ItemPedido.cs`
- `src/Barbara.Domain/Entities/Pagamento.cs`
- `src/Barbara.Domain/Entities/NotaFiscal.cs`
- `src/Barbara.Domain/Entities/Envio.cs`
- `src/Barbara.Domain/Entities/Configuracao.cs`
- `src/Barbara.Domain/Entities/ImagemProduto.cs`
- `src/Barbara.Domain/Entities/EstoqueProduto.cs`

**Template:**

```csharp
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Barbara.Domain.Entities;

public class Produto
{
    [BsonId]
    [BsonRepresentation(BsonType.String)]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [BsonElement("nome")]
    [BsonRequired]
    public string Nome { get; set; } = string.Empty;
    
    [BsonElement("sku")]
    [BsonRequired]
    public string SKU { get; set; } = string.Empty;
    
    [BsonElement("preco")]
    public decimal Preco { get; set; }
    
    [BsonElement("categoriaId")]
    [BsonRepresentation(BsonType.String)]
    public Guid CategoriaId { get; set; }
    
    // Navegação (não armazenada)
    [BsonIgnore]
    public Categoria Categoria { get; set; } = null!;
    
    // Embedded documents (arrays)
    [BsonElement("imagens")]
    public List<ImagemProduto> Imagens { get; set; } = new();
    
    [BsonElement("estoque")]
    public List<EstoqueProduto> Estoque { get; set; } = new();
}
```

---

### 4. Configurar MongoDB URI

**Edite o arquivo `.env` na raiz do projeto:**

```env
# Substitua pela SUA URI do MongoDB Atlas
MONGODB_URI=mongodb+srv://usuario:senha@cluster.mongodb.net/barbara?retryWrites=true&w=majority
```

**Como obter a URI:**

1. Acesse https://cloud.mongodb.com
2. Crie um cluster (Free tier M0)
3. Database Access ? Add Database User
4. Network Access ? Add IP Address (Allow access from anywhere: 0.0.0.0/0)
5. Connect ? Connect your application ? Copy connection string
6. Substitua `<password>` pela senha do usuário

---

## ?? PRÓXIMOS PASSOS

### Passo 1: Completar a Migração dos Controllers

```powershell
# 1. Abra cada controller e substitua BarbaraDbContext por IRepository<T>
# 2. Remova using Microsoft.EntityFrameworkCore
# 3. Adicione using Barbara.Infrastructure.Repositories
```

### Passo 2: Testar Build

```powershell
dotnet build
```

### Passo 3: Configurar MongoDB

```powershell
# Edite .env com sua URI do MongoDB Atlas
notepad .env
```

### Passo 4: Rodar a Aplicação

```powershell
cd src/Barbara.API
dotnet run
```

### Passo 5: Testar API

```powershell
# Health check
Invoke-RestMethod -Uri "http://localhost:5000/health"

# Teste completo
.\test-azure-api.ps1 -BaseUrl "http://localhost:5000"
```

---

## ?? DEPLOY NO AZURE

### Opção 1: Azure App Service + MongoDB Atlas

**Vantagens:**
- ? MongoDB Atlas Free (512MB)
- ? App Service Free F1
- ? **Custo: USD 0/mês**
- ? Sem SQL Server (economiza USD 5/mês)

**Passos:**

1. **Criar cluster MongoDB Atlas:**
   ```
   https://cloud.mongodb.com/v2/signup
   ```

2. **Configurar App Service com MongoDB:**
   ```powershell
   # Adicionar URI do MongoDB como variável de ambiente
   az webapp config appsettings set `
     --resource-group barbara-rg `
     --name barbara-api `
     --settings MONGODB_URI="mongodb+srv://..."
   ```

3. **Deploy:**
   ```powershell
   # Via Visual Studio (mesmos passos anteriores)
   # Ou via CLI:
   cd src/Barbara.API
dotnet publish -c Release -o ./publish
   Compress-Archive -Path ./publish/* -DestinationPath ./barbara-api.zip -Force
   az webapp deploy --resource-group barbara-rg --name barbara-api --src-path ./barbara-api.zip --type zip
   ```

### Opção 2: Azure Container Apps + MongoDB Atlas

**Vantagens:**
- ? Escalabilidade automática
- ? Deploy via container
- ? Integração com GitHub Actions

---

## ?? COMPARAÇÃO DE CUSTOS

### Antes (SQL Server):
| Recurso | Custo/mês |
|---------|-----------|
| SQL Database (Basic) | USD 5 |
| App Service (Free F1) | USD 0 |
| **TOTAL** | **USD 5/mês** |

### Depois (MongoDB):
| Recurso | Custo/mês |
|---------|-----------|
| MongoDB Atlas (M0) | USD 0 |
| App Service (Free F1) | USD 0 |
| **TOTAL** | **USD 0/mês** |

**Economia: USD 5/mês (100%!)**

---

## ?? SCRIPTS ATUALIZADOS

Criei novos scripts para MongoDB:

- ? `deploy-azure-mongodb.ps1` - Deploy com MongoDB (aguardando criação)
- ? `test-mongodb-api.ps1` - Teste da API MongoDB (aguardando criação)
- ? `.env` - Configuração de variáveis de ambiente

---

## ?? DOCUMENTAÇÃO

- **MongoDB Atlas:** https://www.mongodb.com/docs/atlas/
- **MongoDB.Driver C#:** https://www.mongodb.com/docs/drivers/csharp/current/
- **Azure App Service:**  https://docs.microsoft.com/azure/app-service/

---

## ? CHECKLIST

- [x] Pacotes MongoDB instalados
- [x] MongoDbContext criado
- [x] Repositório genérico criado
- [x] Program.cs atualizado
- [x] Cliente e Endereco migrados
- [x] .env criado
- [ ] **Controllers atualizados** ? FAZER AGORA
- [ ] **Entidades restantes migradas** ? FAZER DEPOIS
- [ ] MongoDB URI configurada
- [ ] Build compilando
- [ ] Testes locais OK
- [ ] Deploy no Azure
- [ ] Domínio customizado configurado

---

**?? PRÓXIMA AÇÃO:**

1. **Atualizar todos os 5 controllers** para usar `IRepository<T>`
2. Fazer build: `dotnet build`
3. Se compilar, configurar `.env` com MongoDB URI
4. Testar localmente
5. Fazer deploy no Azure

**Status:** 60% concluído | Falta: Controllers + Entidades

---

**?? DICA:** Para acelerar, você pode usar Find & Replace no Visual Studio:

```
Buscar: using Microsoft.EntityFrameworkCore;
Substituir por: using Barbara.Infrastructure.Repositories;

Buscar: BarbaraDbContext _context
Substituir por: IRepository<NOME_ENTIDADE> _repository

Buscar: _context.ENTIDADES
Substituir por: _repository
```

---

**Última atualização:** 2025-01-09 10:00 UTC
