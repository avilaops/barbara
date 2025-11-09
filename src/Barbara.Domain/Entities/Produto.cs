namespace Barbara.Domain.Entities;

public class Produto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
 public string CodigoBarras { get; set; } = string.Empty;
    
    public decimal Preco { get; set; }
    public decimal? PrecoPromocional { get; set; }
    
    // Categoria
    public Guid CategoriaId { get; set; }
    public Categoria Categoria { get; set; } = null!;
    
    // Gênero
    public GeneroRoupa Genero { get; set; }
    
    // Imagens e Modelo 3D
    public ICollection<ImagemProduto> Imagens { get; set; } = new List<ImagemProduto>();
    public string? UrlModelo3D { get; set; } // URL do modelo 3D para provador virtual
    
    // Estoque
    public ICollection<EstoqueProduto> Estoque { get; set; } = new List<EstoqueProduto>();
    
    // Flags
  public bool Ativo { get; set; } = true;
    public bool Destaque { get; set; } = false; // Produto em destaque na home
    
    public DateTime DataCadastro { get; set; }
}

public enum GeneroRoupa
{
    Feminino = 1,
    Masculino = 2,
    Unissex = 3
}
