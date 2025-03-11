using Amazon.Scheduler;
using DietiDeals24.RestApi.Workers;
using DietiDeals24.RestApi.Workers.Impl;

namespace DietiDeals24.RestApi.Extensions;

public static class ConfigureServiceExtensions
{
    public static IServiceCollection AddDietiDeals24Workers(this IServiceCollection services)
    {
        services.AddSingleton<AmazonSchedulerClient>();
        services.AddScoped<EventBridgeSchedulerService>();
        services.AddScoped<ICheckWorker, CheckWorker>();
        services.AddScoped<IAuctionWorker, AuctionWorker>();
        services.AddScoped<IAuthenticationWorker, AuthenticationWorker>();
        services.AddScoped<IVendorWorker, VendorWorker>();
        services.AddScoped<IBidWorker, BidWorker>();
        return services;
    }
}