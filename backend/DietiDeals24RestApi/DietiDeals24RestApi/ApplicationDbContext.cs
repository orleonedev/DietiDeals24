using Microsoft.EntityFrameworkCore;

namespace DietiDeals24RestApi;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : DbContext(options)
{
    //public DbSet<SomeEntity> SomeEntities { get; set; } // Example DbSet
}