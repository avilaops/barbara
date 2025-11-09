namespace Barbara.Domain.Entities;

public class NotaFiscal
{
    public Guid Id { get; set; }
    public Guid PedidoId { get; set; }
    public Pedido Pedido { get; set; } = null!;
    
    public string Numero { get; set; } = string.Empty;
    public string Serie { get; set; } = string.Empty;
    public string ChaveAcesso { get; set; } = string.Empty;
    
    public string? UrlPDF { get; set; }
    public string? UrlXML { get; set; }
    
    public DateTime DataEmissao { get; set; }
    public StatusNotaFiscal Status { get; set; }
    
    // Dados da API de NF-e
    public string? DadosRetornoJson { get; set; }
}

public enum StatusNotaFiscal
{
    Pendente = 1,
    Processando = 2,
    Autorizada = 3,
    Rejeitada = 4,
    Cancelada = 5
}
