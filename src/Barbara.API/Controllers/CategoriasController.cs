using Barbara.Domain.Entities;
using Barbara.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Barbara.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriasController : ControllerBase
{
    private readonly IRepository<Categoria> _repository;

    public CategoriasController(IRepository<Categoria> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Categoria>>> GetCategorias()
    {
        var categorias = await _repository.FindAsync(c => c.Ativa);
      return Ok(categorias.OrderBy(c => c.Nome));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Categoria>> GetCategoria(Guid id)
    {
        var categoria = await _repository.GetByIdAsync(id);
   if (categoria == null)
        {
          return NotFound();
      }
        return Ok(categoria);
    }

  [HttpPost]
    public async Task<ActionResult<Categoria>> CriarCategoria(Categoria categoria)
    {
      var created = await _repository.AddAsync(categoria);
        return CreatedAtAction(nameof(GetCategoria), new { id = created.Id }, created);
  }

    [HttpPut("{id}")]
    public async Task<IActionResult> AtualizarCategoria(Guid id, Categoria categoria)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null)
        {
            return NotFound();
        }

        categoria.Id = id;
        await _repository.UpdateAsync(id, categoria);
        return NoContent();
    }

 [HttpDelete("{id}")]
    public async Task<IActionResult> DeletarCategoria(Guid id)
    {
        var categoria = await _repository.GetByIdAsync(id);
   if (categoria == null)
        {
            return NotFound();
        }

        await _repository.DeleteAsync(id);
        return NoContent();
    }
}
