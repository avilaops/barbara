using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Barbara.Domain.Entities;

public class Cliente
{
    [BsonId]
    [BsonRepresentation(BsonType.String)]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [BsonElement("nome")]
    [BsonRequired]
    public string Nome { get; set; } = string.Empty;
    
    [BsonElement("email")]
    [BsonRequired]
    public string Email { get; set; } = string.Empty;
    
    [BsonElement("telefone")]
    public string Telefone { get; set; } = string.Empty;
    
    [BsonElement("cpf")]
    [BsonRequired]
    public string CPF { get; set; } = string.Empty;
    
    [BsonElement("dataCadastro")]
    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    // Dados do Avatar para Provador Virtual
    [BsonElement("altura")]
    [BsonIgnoreIfNull]
    public decimal? Altura { get; set; }
    
    [BsonElement("peso")]
    [BsonIgnoreIfNull]
    public decimal? Peso { get; set; }
    
    [BsonElement("manequim")]
    [BsonIgnoreIfNull]
    public string? Manequim { get; set; }
    
    [BsonElement("avatarConfig")]
    [BsonIgnoreIfNull]
    public string? AvatarConfigJson { get; set; }
    
    // Endereços (embedded documents)
    [BsonElement("enderecos")]
    public List<Endereco> Enderecos { get; set; } = new();
    
    // Pedidos (apenas IDs para referência)
    [BsonElement("pedidoIds")]
    [BsonIgnoreIfDefault]
    public List<Guid> PedidoIds { get; set; } = new();
    
    // Navegação (não armazenada no MongoDB)
    [BsonIgnore]
    public ICollection<Pedido> Pedidos { get; set; } = new List<Pedido>();
}
