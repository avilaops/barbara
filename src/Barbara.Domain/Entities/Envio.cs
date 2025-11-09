namespace Barbara.Domain.Entities;

public class Envio
{
    public Guid Id { get; set; }
    public Guid PedidoId { get; set; }
    public Pedido Pedido { get; set; } = null!;
    
    public string Transportadora { get; set; } = string.Empty;
    public string CodigoRastreio { get; set; } = string.Empty;
    
    public string? UrlEtiqueta { get; set; }
    public decimal ValorFrete { get; set; }
    public int PrazoEntregaDias { get; set; }
    
    public DateTime? DataColeta { get; set; }
    public DateTime? DataPostagem { get; set; }
public DateTime? DataEntrega { get; set; }
    
    public StatusEnvio Status { get; set; }
    
    // Dados da API da transportadora
    public string? DadosTransportadoraJson { get; set; }
}

public enum StatusEnvio
{
    AguardandoColeta = 1,
    ColetaAgendada = 2,
    EmTransito = 3,
    SaiuParaEntrega = 4,
    Entregue = 5,
  Devolvido = 6,
    Extraviado = 7
}
