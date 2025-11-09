namespace Barbara.Domain.Entities;

public class Configuracao
{
    public Guid Id { get; set; }
    public string Chave { get; set; } = string.Empty;
  public string Valor { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public DateTime UltimaAtualizacao { get; set; }
}
