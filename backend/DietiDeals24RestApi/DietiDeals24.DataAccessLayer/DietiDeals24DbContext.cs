using Microsoft.EntityFrameworkCore;

namespace DietiDeals24.DataAccessLayer;

public class DietiDeals24DbContext(DbContextOptions<DietiDeals24DbContext> options) : DbContext(options)
{
   
}