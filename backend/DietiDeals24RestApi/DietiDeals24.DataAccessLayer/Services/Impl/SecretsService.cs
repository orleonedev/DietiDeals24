using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class SecretsService : ISecretsService
{
    private readonly ILogger<SecretsService> _logger;
    private readonly List<string> _requiredSecrets;

    public SecretsService(ILogger<SecretsService> logger, List<string>? requiredSecrets = null)
    {
        _logger = logger;
        _requiredSecrets = requiredSecrets ?? new List<string>();
    }

    /// <summary>
    /// Retrieves all the secrets and then validates them
    /// </summary>
    /// <returns></returns>
    public Task<Dictionary<string, string>> GetSecretsAsync()
    {
        _logger.LogInformation("Fetching secrets from environment variables...");

        var secrets = Environment.GetEnvironmentVariables()
            .Cast<System.Collections.DictionaryEntry>()
            .ToDictionary(entry => entry.Key.ToString(), entry => entry.Value?.ToString());

        ValidateSecrets(secrets);

        return Task.FromResult(secrets);
    }

    /// <summary>
    /// Retrieves a single secret
    /// </summary>
    /// <param name="key"></param>
    /// <returns></returns>
    /// <exception cref="Exception"></exception>
    public Task<string> GetSecretValueAsync(string key)
    {
        var value = Environment.GetEnvironmentVariable(key);

        if (string.IsNullOrWhiteSpace(value))
        {
            throw new Exception($"Secret '{key}' is missing or invalid.");
        }

        return Task.FromResult(value);
    }

    private void ValidateSecrets(Dictionary<string, string> secrets)
    {
        if (_requiredSecrets.Count == 0)
        {
            _logger.LogInformation("No specific secrets to validate.");
            return;
        }

        foreach (var key in _requiredSecrets)
        {
            if (!secrets.TryGetValue(key, out var value) || string.IsNullOrWhiteSpace(value))
            {
                throw new InvalidOperationException($"Missing or invalid secret: {key}");
            }
        }
    }
}
