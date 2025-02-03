using System.Net;
using System.Threading.Tasks;
using Amazon.CognitoIdentityProvider.Model;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.DataAccessLayer.Services;

public interface IAuthenticationService
{
    public Task<AdminGetUserResponse> RegisterUserAsync(string fullName, string username, string password, string email,
        string birthDate, string gender);

    public Task<TokenResponseDTO> LoginUserAsync(string email, string password);
    public Task LogoutUserAsync(string accessToken);
    public Task<HttpStatusCode> ConfirmUserAsync(string email, string confirmationCode);
    public Task ResendConfirmationCodeAsync(string email);
    public Task<AdminGetUserResponse> GetUserAsync(string email);
    public Task<string> GetCognitoSub(string email);
    public Task<TokenResponseDTO> RefreshTokenAsync(string refreshToken);
}