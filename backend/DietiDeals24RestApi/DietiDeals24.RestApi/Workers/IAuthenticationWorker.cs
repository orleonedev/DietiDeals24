using System.Net;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.RestApi.Workers;

public interface IAuthenticationWorker
{
    public Task<UserResponseDTO> RegisterUserAsync(RegistrationDTO registrationDto);
    public Task<TokenResponseDTO> LoginUserAsync(LoginDTO loginDto);
    public Task LogoutUserAsync(LogoutDTO logoutDto);
    public Task ConfirmUserAsync(ConfirmUserDTO confirmUserDto);
    
    public Task ResendConfirmationCodeAsync(ResendCodeDTO resendCodeDto);
    public Task<TokenResponseDTO> RefreshTokenAsync(RefreshTokenDTO refreshTokenDto);
}