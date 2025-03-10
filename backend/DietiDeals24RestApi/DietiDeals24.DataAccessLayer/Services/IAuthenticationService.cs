using System;
using System.Net;
using System.Threading.Tasks;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IAuthenticationService
{
    public Task<UserResponseDTO> RegisterUserAsync(RegistrationDTO registrationDto);

    public Task<TokenResponseDTO> LoginUserAsync(string email, string password);
    public Task LogoutUserAsync(string accessToken);
    public Task ConfirmUserAsync(string email, string confirmationCode);
    public Task ResendConfirmationCodeAsync(string email);
    public Task<UserResponseDTO> GetUserAsync(string email);
    public Task<TokenResponseDTO> RefreshTokenAsync(string refreshToken);
    public Task<bool> UpdateVendorStatusAsync(Guid vendorId, string username);
}