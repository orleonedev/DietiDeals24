using System;
using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace DietiDeals24.DataAccessLayer;

public class DietiDeals24DbContext(DbContextOptions<DietiDeals24DbContext> options) : DbContext(options)
{
    public DbSet<User> Users { get; set; }
    public DbSet<Vendor> Vendors { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            // Access the environment variable directly
            string connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING");
    
            if (string.IsNullOrEmpty(connectionString))
            {
                throw new InvalidOperationException("The database connection string is not set in the environment variables.");
            }
    
            optionsBuilder.UseNpgsql(connectionString);
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(DietiDeals24DbContext).Assembly);
    }
}