using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class SecretsService: ISecretsService
{
    private readonly ILogger<SecretsService> _logger;
    private Dictionary<string, string> _secretsCache;
    private DateTime _secretsCacheExpiry;
    private readonly List<string> _requiredSecrets;

    // Constructor that ensures the requiredSecrets is never null
    public SecretsService(ILogger<SecretsService> logger, List<string> requiredSecrets = null)
    {
        _logger = logger;
        _secretsCache = new Dictionary<string, string>();
        // Ensure the requiredSecrets is initialized to an empty list if not provided
        _requiredSecrets = requiredSecrets ?? new List<string>(); 
    }

    /// <summary>
    /// Fetches secrets from environment variables and caches them for better performance.
    /// </summary>
    public async Task<Dictionary<string, string>> GetSecretsAsync()
    {
        // If cache is valid, return it
        if (_secretsCache != null && DateTime.UtcNow <= _secretsCacheExpiry)
        {
            return _secretsCache;
        }

        _logger.LogInformation("Fetching secrets from environment variables...");

        // Fetch all secrets from environment variables dynamically
        var secrets = new Dictionary<string, string>();

        foreach (var key in Environment.GetEnvironmentVariables().Keys)
        {
            var keyString = key.ToString();
            var value = Environment.GetEnvironmentVariable(keyString);
            if (!string.IsNullOrWhiteSpace(value))
            {
                secrets[keyString] = value;
            }
        }

        // Validate the fetched secrets
        ValidateSecrets(secrets);

        // Cache the secrets for 15 minutes
        _secretsCache = secrets;
        _secretsCacheExpiry = DateTime.UtcNow.AddMinutes(15);

        return await Task.FromResult(_secretsCache);
    }

    /// <summary>
    /// Fetches a specific secret value by key.
    /// </summary>
    public async Task<string> GetSecretValueAsync(string key)
    {
        var secrets = await GetSecretsAsync();

        if (!secrets.TryGetValue(key, out var value) || string.IsNullOrWhiteSpace(value))
        {
            throw new Exception($"Secret '{key}' is missing or invalid.");
        }

        return value;
    }

    /// <summary>
    /// Validates the presence of required keys in the secrets dictionary (if any).
    /// </summary>
    private void ValidateSecrets(Dictionary<string, string> secrets)
    {
        // Only validate if requiredSecrets is not empty (the list is never null)
        if (_requiredSecrets.Count == 0)
        {
            _logger.LogInformation("No specific secrets to validate.");
        }
        else
        {
            foreach (var key in _requiredSecrets)
            {
                if (!secrets.TryGetValue(key, out var value) || string.IsNullOrWhiteSpace(value))
                {
                    throw new InvalidOperationException($"Missing or invalid secret: {key}");
                }
            }
        }
    }
}
