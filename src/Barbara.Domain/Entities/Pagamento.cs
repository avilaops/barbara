namespace Barbara.Domain.Entities;

public class Pagamento
{
    public Guid Id { get; set; }
    public Guid PedidoId { get; set; }
    public Pedido Pedido { get; set; } = null!;
    
    public FormaPagamento FormaPagamento { get; set; }
    public StatusPagamento Status { get; set; }
    
    public decimal Valor { get; set; }
    
    // Dados da transação (retornados pelo gateway)
    public string? TransacaoId { get; set; }
  public string? Gateway { get; set; } // Ex: MercadoPago, PagSeguro, Stripe
    public string? DadosTransacaoJson { get; set; }
 
    public DateTime DataCriacao { get; set; }
    public DateTime? DataConfirmacao { get; set; }
}

public enum FormaPagamento
{
    CartaoCredito = 1,
    CartaoDebito = 2,
    PIX = 3,
    Boleto = 4
}

public enum StatusPagamento
{
    Pendente = 1,
    Processando = 2,
    Aprovado = 3,
    Recusado = 4,
    Cancelado = 5,
    Estornado = 6
}
