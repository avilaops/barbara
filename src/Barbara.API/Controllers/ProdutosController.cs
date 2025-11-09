using Barbara.API.DTOs;
using Barbara.Domain.Entities;
using Barbara.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Barbara.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProdutosController : ControllerBase
{
    private readonly IRepository<Produto> _produtoRepository;
    private readonly IRepository<Categoria> _categoriaRepository;

    public ProdutosController(
  IRepository<Produto> produtoRepository,
        IRepository<Categoria> categoriaRepository)
    {
    _produtoRepository = produtoRepository;
        _categoriaRepository = categoriaRepository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProdutoDto>>> GetProdutos(
        [FromQuery] string? busca,
        [FromQuery] Guid? categoriaId,
      [FromQuery] int? genero,
        [FromQuery] int pagina = 1,
        [FromQuery] int tamanhoPagina = 20)
    {
      var produtos = await _produtoRepository.FindAsync(p => p.Ativo);
  
        // Filtros
        if (!string.IsNullOrEmpty(busca))
{
  produtos = produtos.Where(p => 
     p.Nome.Contains(busca, StringComparison.OrdinalIgnoreCase) || 
    p.Descricao.Contains(busca, StringComparison.OrdinalIgnoreCase));
      }

        if (categoriaId.HasValue)
        {
 produtos = produtos.Where(p => p.CategoriaId == categoriaId.Value);
      }

        if (genero.HasValue)
{
      produtos = produtos.Where(p => p.Genero == (GeneroRoupa)genero.Value);
        }

 var total = produtos.Count();
        var produtosPaginados = produtos
 .OrderBy(p => p.Nome)
        .Skip((pagina - 1) * tamanhoPagina)
            .Take(tamanhoPagina)
 .ToList();

        // Buscar categorias
        var categoriaIds = produtosPaginados.Select(p => p.CategoriaId).Distinct();
        var categorias = new Dictionary<Guid, string>();
        foreach (var catId in categoriaIds)
    {
          var cat = await _categoriaRepository.GetByIdAsync(catId);
            if (cat != null)
            {
        categorias[catId] = cat.Nome;
        }
        }

      var produtosDto = produtosPaginados.Select(p => new ProdutoDto
    {
 Id = p.Id,
  Nome = p.Nome,
        Descricao = p.Descricao,
            SKU = p.SKU,
  Preco = p.Preco,
            PrecoPromocional = p.PrecoPromocional,
     Categoria = categorias.GetValueOrDefault(p.CategoriaId, ""),
   Genero = p.Genero.ToString(),
        Imagens = p.Imagens.OrderBy(i => i.Ordem).Select(i => i.Url).ToList(),
            UrlModelo3D = p.UrlModelo3D,
    Estoque = p.Estoque.Select(e => new EstoqueDto
       {
         Id = e.Id,
       Tamanho = e.Tamanho,
                Cor = e.Cor,
       Quantidade = e.Quantidade
            }).ToList()
        }).ToList();

    Response.Headers.Append("X-Total-Count", total.ToString());
        Response.Headers.Append("X-Page", pagina.ToString());
        Response.Headers.Append("X-Page-Size", tamanhoPagina.ToString());

    return Ok(produtosDto);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProdutoDto>> GetProduto(Guid id)
    {
        var produto = await _produtoRepository.GetByIdAsync(id);
        if (produto == null)
        {
       return NotFound();
  }

        var categoria = await _categoriaRepository.GetByIdAsync(produto.CategoriaId);

        var produtoDto = new ProdutoDto
        {
            Id = produto.Id,
            Nome = produto.Nome,
      Descricao = produto.Descricao,
       SKU = produto.SKU,
    Preco = produto.Preco,
          PrecoPromocional = produto.PrecoPromocional,
        Categoria = categoria?.Nome ?? "",
     Genero = produto.Genero.ToString(),
     Imagens = produto.Imagens.OrderBy(i => i.Ordem).Select(i => i.Url).ToList(),
            UrlModelo3D = produto.UrlModelo3D,
            Estoque = produto.Estoque.Select(e => new EstoqueDto
            {
    Id = e.Id,
            Tamanho = e.Tamanho,
          Cor = e.Cor,
         Quantidade = e.Quantidade
            }).ToList()
        };

        return Ok(produtoDto);
    }

    [HttpPost]
    public async Task<ActionResult<ProdutoDto>> CriarProduto(CriarProdutoDto dto)
    {
     var produto = new Produto
     {
       Nome = dto.Nome,
            Descricao = dto.Descricao,
   SKU = dto.SKU,
            CodigoBarras = dto.CodigoBarras,
    Preco = dto.Preco,
   PrecoPromocional = dto.PrecoPromocional,
            CategoriaId = dto.CategoriaId,
 Genero = (GeneroRoupa)dto.Genero,
      UrlModelo3D = dto.UrlModelo3D,
Ativo = true,
            DataCadastro = DateTime.UtcNow
        };

        var created = await _produtoRepository.AddAsync(produto);
        return CreatedAtAction(nameof(GetProduto), new { id = created.Id }, created);
}

  [HttpPut("{id}")]
    public async Task<IActionResult> AtualizarProduto(Guid id, CriarProdutoDto dto)
    {
        var produto = await _produtoRepository.GetByIdAsync(id);
        if (produto == null)
        {
            return NotFound();
        }

        produto.Nome = dto.Nome;
        produto.Descricao = dto.Descricao;
        produto.SKU = dto.SKU;
        produto.CodigoBarras = dto.CodigoBarras;
   produto.Preco = dto.Preco;
        produto.PrecoPromocional = dto.PrecoPromocional;
        produto.CategoriaId = dto.CategoriaId;
        produto.Genero = (GeneroRoupa)dto.Genero;
    produto.UrlModelo3D = dto.UrlModelo3D;

        await _produtoRepository.UpdateAsync(id, produto);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletarProduto(Guid id)
    {
        var produto = await _produtoRepository.GetByIdAsync(id);
        if (produto == null)
   {
            return NotFound();
        }

        produto.Ativo = false; // Soft delete
        await _produtoRepository.UpdateAsync(id, produto);
        return NoContent();
    }

    [HttpGet("destaques")]
    public async Task<ActionResult<IEnumerable<ProdutoDto>>> GetProdutosDestaque()
    {
        var produtos = await _produtoRepository.FindAsync(p => p.Ativo && p.Destaque);
        
        var produtosDto = produtos.Select(p => new ProdutoDto
        {
    Id = p.Id,
            Nome = p.Nome,
      Descricao = p.Descricao,
         SKU = p.SKU,
            Preco = p.Preco,
 PrecoPromocional = p.PrecoPromocional,
            Genero = p.Genero.ToString(),
 Imagens = p.Imagens.OrderBy(i => i.Ordem).Select(i => i.Url).ToList(),
   UrlModelo3D = p.UrlModelo3D
        }).ToList();

        return Ok(produtosDto);
    }

    [HttpGet("categoria/{categoriaId}")]
    public async Task<ActionResult<IEnumerable<ProdutoDto>>> GetProdutosPorCategoria(Guid categoriaId)
    {
    var produtos = await _produtoRepository.FindAsync(p => p.Ativo && p.CategoriaId == categoriaId);
   
        var produtosDto = produtos.Select(p => new ProdutoDto
        {
            Id = p.Id,
Nome = p.Nome,
       Descricao = p.Descricao,
            SKU = p.SKU,
         Preco = p.Preco,
      PrecoPromocional = p.PrecoPromocional,
            Genero = p.Genero.ToString(),
       Imagens = p.Imagens.OrderBy(i => i.Ordem).Select(i => i.Url).ToList(),
    UrlModelo3D = p.UrlModelo3D
        }).ToList();

        return Ok(produtosDto);
    }
}
