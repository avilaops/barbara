namespace Barbara.Domain.Entities;

public class Pedido
{
    public Guid Id { get; set; }
    public string NumeroPedido { get; set; } = string.Empty;
    
    // Cliente
    public Guid ClienteId { get; set; }
    public Cliente Cliente { get; set; } = null!;
    
    // Endereço de Entrega
    public Guid EnderecoEntregaId { get; set; }
    public Endereco EnderecoEntrega { get; set; } = null!;
    
    // Valores
    public decimal SubTotal { get; set; }
    public decimal ValorFrete { get; set; }
    public decimal Desconto { get; set; }
    public decimal Total { get; set; }
    
    // Status
    public StatusPedido Status { get; set; }
 
    // Datas
    public DateTime DataPedido { get; set; }
    public DateTime? DataPagamento { get; set; }
    public DateTime? DataEnvio { get; set; }
    public DateTime? DataEntrega { get; set; }
    
    // Itens
    public ICollection<ItemPedido> Itens { get; set; } = new List<ItemPedido>();
    
    // Pagamento
    public Pagamento? Pagamento { get; set; }
    
    // Nota Fiscal
    public NotaFiscal? NotaFiscal { get; set; }
  
    // Transporte
    public Envio? Envio { get; set; }
}

public enum StatusPedido
{
    Pendente = 0,
    AguardandoPagamento = 1,
    PagamentoConfirmado = 2,
    EmSeparacao = 3,
    AguardandoColeta = 4,
    EmTransito = 5,
    Entregue = 6,
    Cancelado = 7
}
