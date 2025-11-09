namespace Barbara.Domain.Entities;

public class ImagemProduto
{
    public Guid Id { get; set; }
    public Guid ProdutoId { get; set; }
    public Produto Produto { get; set; } = null!;
    
    public string Url { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public int Ordem { get; set; }
    public bool Principal { get; set; }
}
