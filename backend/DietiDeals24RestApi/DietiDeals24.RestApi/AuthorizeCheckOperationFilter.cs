using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace DietiDeals24.RestApi;

/// <summary>
/// This class is an OpenAPI (Swagger) operation filter that checks whether an endpoint requires authorization.
/// If an endpoint has the [Authorize] attribute, it adds JWT Bearer authentication to the Swagger documentation.
/// </summary>
public class AuthorizeCheckOperationFilter : IOperationFilter
{
    /// <summary>
    /// Applies the security requirement to Swagger if the endpoint requires authorization.
    /// </summary>
    /// <param name="operation">The OpenAPI operation being processed.</param>
    /// <param name="context">The context that provides information about the API operation.</param>
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        // Check if the endpoint or its containing class has the [Authorize] attribute
        var hasAuthorize = context.MethodInfo.DeclaringType.GetCustomAttributes(true)
                               .OfType<AuthorizeAttribute>().Any()  // Check at the class level
                           || context.MethodInfo.GetCustomAttributes(true)
                               .OfType<AuthorizeAttribute>().Any(); // Check at the method level

        if (hasAuthorize)
        {
            // If authorization is required, add a security requirement for JWT Bearer authentication
            operation.Security = new List<OpenApiSecurityRequirement>
            {
                new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = JwtBearerDefaults.AuthenticationScheme // "Bearer" authentication scheme
                            }
                        },
                        Array.Empty<string>() // No specific scopes required
                    }
                }
            };
        }
    }
}