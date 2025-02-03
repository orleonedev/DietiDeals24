using System.Data.Common;
using Amazon.CognitoIdentityProvider.Model;
using DietiDeals24.RestApi.Models;
using DietiDeals24.RestApi.Models;
using Microsoft.AspNetCore.Mvc;

namespace DietiDeals24.RestApi.Workers;

public interface IAuthenticationWorker
{
    public Task<AdminGetUserResponse> RegisterUserAsync(RegistrationDTO registrationDto);
    public Task<TokenResponseDTO> LoginUserAsync(string email, string password);
    public Task<string> ConfirmUserAsync(ConfirmUserDTO confirmUserDto);
    public Task<TokenResponseDTO> RefreshTokenAsync(string refreshToken);
}