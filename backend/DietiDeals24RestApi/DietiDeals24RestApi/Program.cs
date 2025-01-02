using System.Reflection;
using DietiDeals24.DataAccessLayer.Extensions;
using DietiDeals24RestApi.Workers;
using DietiDeals24RestApi.Workers.Impl;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
namespace DietiDeals24RestApi;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.
        // var connectionString = builder.Configuration["DB_CONNECTION_STRING"];
        
        builder.Services.AddDietiDeals24DataAccessLayer(builder.Configuration);
        // builder.Services.AddDbContext<ApplicationDbContext>(options =>
        //     options.UseNpgsql(connectionString));

        builder.Services.AddScoped<ICheckWorker, CheckWorker>();
        builder.Services.AddControllers();
        // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(options =>
        {
            // Specify the path to the generated XML file
            var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            options.IncludeXmlComments(xmlPath);
            options.EnableAnnotations();

        });

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseHttpsRedirection();

        app.UseAuthorization();


        app.MapControllers();

        app.Run();
    }
}