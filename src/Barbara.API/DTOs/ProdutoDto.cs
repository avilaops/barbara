namespace Barbara.API.DTOs;

public class ProdutoDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
  public string Descricao { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
  public decimal Preco { get; set; }
    public decimal? PrecoPromocional { get; set; }
    public string Categoria { get; set; } = string.Empty;
    public string Genero { get; set; } = string.Empty;
    public List<string> Imagens { get; set; } = new();
    public string? UrlModelo3D { get; set; }
    public List<EstoqueDto> Estoque { get; set; } = new();
}

public class EstoqueDto
{
    public Guid Id { get; set; }
    public string Tamanho { get; set; } = string.Empty;
    public string? Cor { get; set; }
    public int Quantidade { get; set; }
    public bool Disponivel => Quantidade > 0;
}

public class CriarProdutoDto
{
    public string Nome { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    public string CodigoBarras { get; set; } = string.Empty;
    public decimal Preco { get; set; }
    public decimal? PrecoPromocional { get; set; }
    public Guid CategoriaId { get; set; }
    public int Genero { get; set; }
    public string? UrlModelo3D { get; set; }
}
