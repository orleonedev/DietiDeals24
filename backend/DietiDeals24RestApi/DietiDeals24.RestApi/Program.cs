using System.IdentityModel.Tokens.Jwt;
using System.Reflection;
using System.Text;
using Amazon.CognitoIdentityProvider;
using DietiDeals24.DataAccessLayer.Extensions;
using DietiDeals24.RestApi.Extensions;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Net.Http.Headers;
using Microsoft.OpenApi.Models;

namespace DietiDeals24.RestApi;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.
        builder.Services.AddDietiDeals24DataAccessLayer(builder.Configuration);
        builder.Services.AddDietiDeals24Workers();
        
        // Configure JWT Authentication
        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.RequireHttpsMetadata = false; // Allow HTTP for metadata in development
                options.Authority = $"https://cognito-idp.{Environment.GetEnvironmentVariable("COGNITO_CLIENT_ID")}.amazonaws.com/{Environment.GetEnvironmentVariable("USER_POOL_ID")}";
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = $"https://cognito-idp.{Environment.GetEnvironmentVariable("AWS_REGION")}.amazonaws.com/{Environment.GetEnvironmentVariable("USER_POOL_ID")}",
                    ValidAudience = Environment.GetEnvironmentVariable("COGNITO_CLIENT_ID"),
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("my-secret-key")), //da sostituire
                    RoleClaimType = "scope"
                };
            });
        
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
            
            options.AddSecurityDefinition(JwtBearerDefaults.AuthenticationScheme, new OpenApiSecurityScheme
            {
                Name = HeaderNames.Authorization,
                Type = SecuritySchemeType.Http,
                Scheme = JwtBearerDefaults.AuthenticationScheme,
                BearerFormat = JwtConstants.HeaderType,
                In = ParameterLocation.Header,
                Description = "Insert JWT Bearer token"
            });

            options.OperationFilter<AuthorizeCheckOperationFilter>();
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