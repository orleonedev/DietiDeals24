using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Services;
using DietiDeals24.DataAccessLayer.Services.Impl;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
namespace DietiDeals24.DataAccessLayer.Extensions;

public static class ConfigureServiceExtensions
{
    public static IServiceCollection AddDietiDeals24DataAccessLayer(this IServiceCollection serviceCollection,
        IConfiguration configuration)
    {
        serviceCollection.AddDbContext<DietiDeals24DbContext>( options =>
            options.UseNpgsql(configuration["DB_CONNECTION_STRING"])
            );
        serviceCollection.AddScoped(typeof(IRepository<,>), typeof(Repository<,>));
        serviceCollection.AddScoped<IUnitOfWork, UnitOfWork>();
        serviceCollection.AddScoped<ICheckService, CheckService>();
        serviceCollection.AddScoped<IAuctionService, AuctionService>();
        return serviceCollection;
    }
    
}