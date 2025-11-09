using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Barbara.Domain.Entities;

public class Endereco
{
    [BsonElement("id")]
    [BsonRepresentation(BsonType.String)]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [BsonElement("cep")]
    [BsonRequired]
    public string CEP { get; set; } = string.Empty;
    
    [BsonElement("logradouro")]
    [BsonRequired]
    public string Logradouro { get; set; } = string.Empty;
    
    [BsonElement("numero")]
    public string Numero { get; set; } = string.Empty;
    
    [BsonElement("complemento")]
    [BsonIgnoreIfNull]
    public string? Complemento { get; set; }
    
    [BsonElement("bairro")]
    public string Bairro { get; set; } = string.Empty;
    
    [BsonElement("cidade")]
    [BsonRequired]
    public string Cidade { get; set; } = string.Empty;
    
    [BsonElement("estado")]
    [BsonRequired]
    public string Estado { get; set; } = string.Empty;
    
    [BsonElement("principal")]
    public bool Principal { get; set; }
 
    // Propriedades de navegação (não armazenadas)
    [BsonIgnore]
    public Guid ClienteId { get; set; }
 
    [BsonIgnore]
    public Cliente Cliente { get; set; } = null!;
}
