namespace Barbara.Domain.Entities;

public class ItemPedido
{
    public Guid Id { get; set; }
    public Guid PedidoId { get; set; }
    public Pedido Pedido { get; set; } = null!;
    
    public Guid ProdutoId { get; set; }
    public Produto Produto { get; set; } = null!;
    
    public Guid EstoqueProdutoId { get; set; }
    public EstoqueProduto EstoqueProduto { get; set; } = null!;
    
    public int Quantidade { get; set; }
    public decimal PrecoUnitario { get; set; }
    public decimal Subtotal { get; set; }
  
    // Informações do produto selecionado
    public string? Tamanho { get; set; }
    public string? Cor { get; set; }
}
