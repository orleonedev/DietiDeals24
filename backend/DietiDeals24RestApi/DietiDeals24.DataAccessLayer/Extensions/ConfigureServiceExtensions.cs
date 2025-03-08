using Amazon;
using Amazon.CognitoIdentityProvider;
using Amazon.S3;
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
        serviceCollection.AddScoped<IVendorService, VendorService>();
        serviceCollection.AddScoped<IBidService, BidService>();
        serviceCollection.AddAWSService<IAmazonCognitoIdentityProvider>();
        serviceCollection.AddAWSService<IAmazonS3>();
        serviceCollection.AddScoped<IImageService, ImageService>();
        serviceCollection.AddSingleton<ISecretsService, SecretsService>();
        serviceCollection.AddScoped<IAuthenticationService, AuthenticationService>();
        return serviceCollection;
    }
    
}