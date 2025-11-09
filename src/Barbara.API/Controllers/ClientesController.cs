using Barbara.Domain.Entities;
using Barbara.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Barbara.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ClientesController : ControllerBase
{
    private readonly IRepository<Cliente> _repository;

    public ClientesController(IRepository<Cliente> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Cliente>>> GetClientes()
    {
        var clientes = await _repository.GetAllAsync();
return Ok(clientes);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Cliente>> GetCliente(Guid id)
 {
        var cliente = await _repository.GetByIdAsync(id);
     if (cliente == null)
     return NotFound();

    return Ok(cliente);
    }

    [HttpPost]
    public async Task<ActionResult<Cliente>> CriarCliente(CriarClienteDto dto)
    {
 // Validar se email já existe
  var clientesComEmail = await _repository.FindAsync(c => c.Email == dto.Email);
        if (clientesComEmail.Any())
       return BadRequest("Email já cadastrado");

        // Validar se CPF já existe
        var clientesComCpf = await _repository.FindAsync(c => c.CPF == dto.CPF);
  if (clientesComCpf.Any())
       return BadRequest("CPF já cadastrado");

   var cliente = new Cliente
        {
         Nome = dto.Nome,
   Email = dto.Email,
     Telefone = dto.Telefone,
 CPF = dto.CPF,
            DataCadastro = DateTime.UtcNow
    };

      var created = await _repository.AddAsync(cliente);
        return CreatedAtAction(nameof(GetCliente), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> AtualizarCliente(Guid id, AtualizarClienteDto dto)
    {
        var cliente = await _repository.GetByIdAsync(id);
        if (cliente == null)
    return NotFound();

        cliente.Nome = dto.Nome;
        cliente.Telefone = dto.Telefone;

    await _repository.UpdateAsync(id, cliente);
  return NoContent();
    }

  [HttpGet("{id}/medidas")]
    public async Task<ActionResult<MedidasDto>> GetMedidas(Guid id)
    {
   var cliente = await _repository.GetByIdAsync(id);
 if (cliente == null)
            return NotFound();

        var medidas = new MedidasDto
        {
       Altura = cliente.Altura,
    Peso = cliente.Peso,
     Manequim = cliente.Manequim
        };

        return Ok(medidas);
    }

    [HttpPut("{id}/medidas")]
    public async Task<IActionResult> AtualizarMedidas(Guid id, MedidasDto dto)
    {
        var cliente = await _repository.GetByIdAsync(id);
if (cliente == null)
  return NotFound();

        cliente.Altura = dto.Altura;
    cliente.Peso = dto.Peso;
        cliente.Manequim = dto.Manequim;

        await _repository.UpdateAsync(id, cliente);
        return NoContent();
    }

    [HttpPost("{id}/enderecos")]
    public async Task<ActionResult<Endereco>> AdicionarEndereco(Guid id, CriarEnderecoDto dto)
    {
        var cliente = await _repository.GetByIdAsync(id);
        if (cliente == null)
   return NotFound();

        var endereco = new Endereco
     {
            CEP = dto.CEP,
     Logradouro = dto.Logradouro,
       Numero = dto.Numero,
            Complemento = dto.Complemento,
   Bairro = dto.Bairro,
      Cidade = dto.Cidade,
     Estado = dto.Estado,
 Principal = dto.Principal
  };

   // Se for principal, desmarcar outros
    if (endereco.Principal)
        {
     foreach (var e in cliente.Enderecos)
                e.Principal = false;
      }

 cliente.Enderecos.Add(endereco);
    await _repository.UpdateAsync(id, cliente);

        return CreatedAtAction(nameof(GetCliente), new { id = cliente.Id }, endereco);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletarCliente(Guid id)
    {
  var cliente = await _repository.GetByIdAsync(id);
  if (cliente == null)
     return NotFound();

 await _repository.DeleteAsync(id);
        return NoContent();
    }
}

public record CriarClienteDto(string Nome, string Email, string Telefone, string CPF);
public record AtualizarClienteDto(string Nome, string Telefone);
public record MedidasDto
{
  public decimal? Altura { get; set; }
 public decimal? Peso { get; set; }
    public string? Manequim { get; set; }
}
public record CriarEnderecoDto(
    string CEP, 
    string Logradouro, 
    string Numero, 
string? Complemento,
    string Bairro,
 string Cidade,
    string Estado,
    bool Principal
);
