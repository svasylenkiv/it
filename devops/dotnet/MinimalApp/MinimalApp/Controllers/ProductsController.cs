using Microsoft.AspNetCore.Mvc;
using MinimalApp.Data;
using MinimalApp.Models;

namespace MinimalApp.Controllers;

[ApiController]
[Route("[controller]")]
public class ProductsController : ControllerBase
{
    private readonly AppDbContext _context;

    public ProductsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public IEnumerable<Product> Get() => _context.Products.ToList();

    [HttpPost]
    public IActionResult Post(Product product)
    {
        _context.Products.Add(product);
        _context.SaveChanges();
        return CreatedAtAction(nameof(Get), new { id = product.Id }, product);
    }
}
