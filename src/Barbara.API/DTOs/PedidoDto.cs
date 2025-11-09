namespace Barbara.API.DTOs;

public class PedidoDto
{
    public Guid Id { get; set; }
    public string NumeroPedido { get; set; } = string.Empty;
    public Guid ClienteId { get; set; }
    public string NomeCliente { get; set; } = string.Empty;
    
    public EnderecoEntregaDto EnderecoEntrega { get; set; } = new();
    
    public List<ItemPedidoDto> Itens { get; set; } = new();
 
    public decimal SubTotal { get; set; }
    public decimal ValorFrete { get; set; }
    public decimal Desconto { get; set; }
    public decimal Total { get; set; }
    
    public string Status { get; set; } = string.Empty;
    
  public DateTime DataPedido { get; set; }
    public DateTime? DataPagamento { get; set; }
    public DateTime? DataEnvio { get; set; }
    public DateTime? DataEntrega { get; set; }
    
    public PagamentoDto? Pagamento { get; set; }
    public string? CodigoRastreio { get; set; }
}

public class ItemPedidoDto
{
 public Guid Id { get; set; }
    public Guid ProdutoId { get; set; }
    public string NomeProduto { get; set; } = string.Empty;
    public string ImagemUrl { get; set; } = string.Empty;
    public string Tamanho { get; set; } = string.Empty;
    public string? Cor { get; set; }
    public int Quantidade { get; set; }
    public decimal PrecoUnitario { get; set; }
 public decimal Subtotal { get; set; }
}

public class EnderecoEntregaDto
{
    public string CEP { get; set; } = string.Empty;
    public string Logradouro { get; set; } = string.Empty;
    public string Numero { get; set; } = string.Empty;
    public string? Complemento { get; set; }
    public string Bairro { get; set; } = string.Empty;
 public string Cidade { get; set; } = string.Empty;
    public string Estado { get; set; } = string.Empty;
}

public class PagamentoDto
{
    public Guid Id { get; set; }
    public string FormaPagamento { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public decimal Valor { get; set; }
    public string? TransacaoId { get; set; }
    public DateTime? DataConfirmacao { get; set; }
}

public class CriarPedidoDto
{
    public Guid ClienteId { get; set; }
  public Guid EnderecoEntregaId { get; set; }
    public List<ItemPedidoRequestDto> Itens { get; set; } = new();
    public FormaPagamentoEnum FormaPagamento { get; set; }
    public string? CupomDesconto { get; set; }
}

public class ItemPedidoRequestDto
{
    public Guid ProdutoId { get; set; }
    public Guid EstoqueProdutoId { get; set; }
    public int Quantidade { get; set; }
}

public enum FormaPagamentoEnum
{
    CartaoCredito = 1,
    CartaoDebito = 2,
    PIX = 3,
    Boleto = 4
}

public class CalcularFreteDto
{
    public string CEPDestino { get; set; } = string.Empty;
    public List<ItemFreteDto> Itens { get; set; } = new();
}

public class ItemFreteDto
{
    public Guid ProdutoId { get; set; }
    public int Quantidade { get; set; }
}

public class FreteResultDto
{
    public decimal Valor { get; set; }
    public int PrazoEntregaDias { get; set; }
    public string Transportadora { get; set; } = string.Empty;
}
