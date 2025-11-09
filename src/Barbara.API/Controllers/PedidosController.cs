using Barbara.Domain.Entities;
using Barbara.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Barbara.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PedidosController : ControllerBase
{
    private readonly IRepository<Pedido> _pedidoRepository;
    private readonly IRepository<Cliente> _clienteRepository;
    private readonly IRepository<Produto> _produtoRepository;

    public PedidosController(
        IRepository<Pedido> pedidoRepository,
        IRepository<Cliente> clienteRepository,
        IRepository<Produto> produtoRepository)
    {
        _pedidoRepository = pedidoRepository;
     _clienteRepository = clienteRepository;
        _produtoRepository = produtoRepository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Pedido>>> GetPedidos([FromQuery] Guid? clienteId)
    {
        if (clienteId.HasValue)
        {
            var pedidos = await _pedidoRepository.FindAsync(p => p.ClienteId == clienteId.Value);
            return Ok(pedidos);
        }
 
        var todosPedidos = await _pedidoRepository.GetAllAsync();
        return Ok(todosPedidos);
}

    [HttpGet("{id}")]
    public async Task<ActionResult<Pedido>> GetPedido(Guid id)
    {
      var pedido = await _pedidoRepository.GetByIdAsync(id);
        if (pedido == null)
return NotFound();

        return Ok(pedido);
    }

    [HttpPost]
    public async Task<ActionResult<Pedido>> CriarPedido(CriarPedidoDto dto)
    {
        // Validar cliente
        var cliente = await _clienteRepository.GetByIdAsync(dto.ClienteId);
        if (cliente == null)
            return BadRequest("Cliente não encontrado");

        // Criar pedido
 var pedido = new Pedido
 {
  ClienteId = dto.ClienteId,
     NumeroPedido = GerarNumeroPedido(),
            DataPedido = DateTime.UtcNow,
       Status = StatusPedido.Pendente,
SubTotal = 0,
  ValorFrete = dto.ValorFrete ?? 0,
            Desconto = dto.Desconto ?? 0
        };

        // Adicionar itens (simplificado - em produção validar produtos e estoque)
        decimal subtotal = 0;
     foreach (var itemDto in dto.Itens)
        {
            var produto = await _produtoRepository.GetByIdAsync(itemDto.ProdutoId);
    if (produto == null) continue;

  var item = new ItemPedido
            {
    ProdutoId = itemDto.ProdutoId,
    Quantidade = itemDto.Quantidade,
      PrecoUnitario = produto.Preco,
      Subtotal = produto.Preco * itemDto.Quantidade,
                Tamanho = itemDto.Tamanho,
 Cor = itemDto.Cor
   };

    pedido.Itens.Add(item);
            subtotal += item.Subtotal;
        }

        pedido.SubTotal = subtotal;
     pedido.Total = subtotal + pedido.ValorFrete - pedido.Desconto;

   var created = await _pedidoRepository.AddAsync(pedido);
        return CreatedAtAction(nameof(GetPedido), new { id = created.Id }, created);
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> AtualizarStatus(Guid id, [FromBody] StatusPedido novoStatus)
    {
    var pedido = await _pedidoRepository.GetByIdAsync(id);
        if (pedido == null)
   return NotFound();

        pedido.Status = novoStatus;
        await _pedidoRepository.UpdateAsync(id, pedido);
        return NoContent();
}

    [HttpDelete("{id}")]
    public async Task<IActionResult> CancelarPedido(Guid id)
    {
        var pedido = await _pedidoRepository.GetByIdAsync(id);
        if (pedido == null)
          return NotFound();

        pedido.Status = StatusPedido.Cancelado;
        await _pedidoRepository.UpdateAsync(id, pedido);
return NoContent();
    }

    [HttpGet("cliente/{clienteId}")]
    public async Task<ActionResult<IEnumerable<Pedido>>> GetPedidosPorCliente(Guid clienteId)
{
        var pedidos = await _pedidoRepository.FindAsync(p => p.ClienteId == clienteId);
    return Ok(pedidos);
}

    private string GerarNumeroPedido()
    {
        return $"PED-{DateTime.UtcNow:yyyyMMddHHmmss}-{Guid.NewGuid().ToString().Substring(0, 4).ToUpper()}";
 }
}

public record CriarPedidoDto(
    Guid ClienteId,
    List<CriarItemPedidoDto> Itens,
    decimal? ValorFrete,
    decimal? Desconto
);

public record CriarItemPedidoDto(
 Guid ProdutoId,
    int Quantidade,
    string? Tamanho,
    string? Cor
);
