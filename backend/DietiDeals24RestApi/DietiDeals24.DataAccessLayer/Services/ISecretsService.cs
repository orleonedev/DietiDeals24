using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Entities;

namespace DietiDeals24.DataAccessLayer.Services;

public interface ISecretsService
{
    public Task<Dictionary<string, string>> GetSecretsAsync();
    public Task<string> GetSecretValueAsync(string key);
}