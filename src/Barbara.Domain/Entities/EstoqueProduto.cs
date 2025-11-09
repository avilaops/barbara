namespace Barbara.Domain.Entities;

public class EstoqueProduto
{
    public Guid Id { get; set; }
    public Guid ProdutoId { get; set; }
    public Produto Produto { get; set; } = null!;
    
    public string Tamanho { get; set; } = string.Empty; // PP, P, M, G, GG, XG, etc.
    public string? Cor { get; set; }
    public int Quantidade { get; set; }
    public int QuantidadeMinima { get; set; } = 5;
}
