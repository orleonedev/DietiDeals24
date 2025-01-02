using DietiDeals24.RestApi.Workers;

namespace DietiDeals24.RestApi.Extensions;

public static class ConfigureServiceExtensions
{
    public static IServiceCollection AddDietiDeals24Workers(this IServiceCollection services)
    {
        services.AddScoped<ICheckWorker, CheckWorker>();
        return services;
    }
}