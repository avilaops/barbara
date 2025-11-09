namespace Barbara.Domain.Entities;

public class Categoria
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public bool Ativa { get; set; } = true;
    
public ICollection<Produto> Produtos { get; set; } = new List<Produto>();
}
