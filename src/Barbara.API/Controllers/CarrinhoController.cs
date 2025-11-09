using Barbara.Domain.Entities;
using Barbara.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Barbara.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CarrinhoController : ControllerBase
{
    private readonly IRepository<Cliente> _clienteRepository;
 private readonly IRepository<Produto> _produtoRepository;

    public CarrinhoController(
    IRepository<Cliente> clienteRepository,
        IRepository<Produto> produtoRepository)
    {
 _clienteRepository = clienteRepository;
    _produtoRepository = produtoRepository;
    }

 // NOTA: Em produção, usar sessão ou Redis para carrinho temporário
  // Por ora, simplificando com retorno de DTOs

    [HttpPost("adicionar")]
    public async Task<ActionResult<CarrinhoItemDto>> AdicionarItem(AdicionarCarrinhoDto dto)
    {
      var produto = await _produtoRepository.GetByIdAsync(dto.ProdutoId);
        if (produto == null)
     return NotFound("Produto não encontrado");

        var item = new CarrinhoItemDto
        {
          ProdutoId = produto.Id,
  ProdutoNome = produto.Nome,
  Quantidade = dto.Quantidade,
  PrecoUnitario = produto.Preco,
            Subtotal = produto.Preco * dto.Quantidade,
  Tamanho = dto.Tamanho,
     Cor = dto.Cor
  };

   return Ok(item);
 }

    [HttpGet("{clienteId}")]
    public async Task<ActionResult<CarrinhoDto>> GetCarrinho(Guid clienteId)
  {
        // Em produção, buscar do Redis ou sessão
        // Por ora, retornar carrinho vazio
return Ok(new CarrinhoDto
  {
       ClienteId = clienteId,
    Itens = new List<CarrinhoItemDto>(),
            Total = 0
    });
    }

    [HttpDelete("{clienteId}/item/{produtoId}")]
    public async Task<IActionResult> RemoverItem(Guid clienteId, Guid produtoId)
    {
  // Implementar remoção do carrinho
     return NoContent();
    }

    [HttpDelete("{clienteId}/limpar")]
    public async Task<IActionResult> LimparCarrinho(Guid clienteId)
    {
        // Implementar limpeza do carrinho
  return NoContent();
    }
}

public record AdicionarCarrinhoDto(
    Guid ProdutoId,
    int Quantidade,
    string? Tamanho,
    string? Cor
);

public record CarrinhoItemDto
{
    public Guid ProdutoId { get; set; }
    public string ProdutoNome { get; set; } = string.Empty;
    public int Quantidade { get; set; }
    public decimal PrecoUnitario { get; set; }
    public decimal Subtotal { get; set; }
    public string? Tamanho { get; set; }
    public string? Cor { get; set; }
}

public record CarrinhoDto
{
    public Guid ClienteId { get; set; }
  public List<CarrinhoItemDto> Itens { get; set; } = new();
    public decimal Total { get; set; }
}
