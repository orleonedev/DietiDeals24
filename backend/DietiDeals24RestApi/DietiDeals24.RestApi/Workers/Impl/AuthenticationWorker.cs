using System.Net;
using Amazon.CognitoIdentity;
using Amazon.CognitoIdentityProvider.Model;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Services;
using DietiDeals24.DataAccessLayer.Models;

namespace DietiDeals24.RestApi.Workers.Impl;

public class AuthenticationWorker: IAuthenticationWorker
{
    private readonly ILogger<AuthenticationWorker> _logger; // Logger for tracking events and errors
    private readonly IAuthenticationService _authenticationService; // Interfaccia per Cognito
    private readonly IUnitOfWork _repository; // Repository per il database locale

    public AuthenticationWorker(
        ILogger<AuthenticationWorker> logger,
        IAuthenticationService authenticationService,
        IUnitOfWork repository)
    {
        _logger = logger;
        _authenticationService = authenticationService;
        _repository = repository;
    }

    /// <summary>
    /// Registers user and the save the data in the repository
    /// </summary>
    /// <param name="registrationDto"></param>
    public async Task<UserResponseDTO> RegisterUserAsync(RegistrationDTO registrationDto)
    {
        try
        {
            // Step 1: Registra l'utente in Cognito
            var user = await _authenticationService.RegisterUserAsync(registrationDto);

            var cognitoSub = await _authenticationService.GetCognitoSubAsync(registrationDto.Email);
            if (string.IsNullOrEmpty(cognitoSub.ToString()))
            {
                throw new AmazonCognitoIdentityException("Cognito sub is missing.");
            }

            return user;
        }
        catch (ArgumentException ex)
        {
            _logger.LogError(ex, $"Failed to register user. Argument exception: {ex.Message}");
            throw new ArgumentException(ex.Message);
        }
        catch (UsernameExistsException ex)
        {
            _logger.LogError(ex, "Failed to register user. Username already exists.");
            throw new UsernameExistsException(ex.Message);
        }
        catch (InvalidPasswordException ex)
        {
            _logger.LogError(ex, "Failed to register user. Password does not meet the complexity requirements.");
            throw new InvalidPasswordException(ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to register user. Exception occurred: {ex.Message}");
            throw new Exception(ex.Message);
        }
    }

    /// <summary>
    /// Login user and updates cognito sub if is missing
    /// </summary>
    /// <param name="email"></param>
    /// <param name="password"></param>
    /// <returns></returns>
    public async Task<TokenResponseDTO> LoginUserAsync(LoginDTO loginDto)
    {
        try
        {
            // Step 1: Esegui il login
            var token = await _authenticationService.LoginUserAsync(loginDto.Email, loginDto.Password);

            // Step 2: Recupera il CognitoSub dall'account
            var cognitoSub = await _authenticationService.GetCognitoSubAsync(loginDto.Email);

            return new TokenResponseDTO
            {
                IdToken = token.IdToken,
                AccessToken = token.AccessToken,
                RefreshToken = token.RefreshToken
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to login user. Exception occurred: {ex.Message}");
            throw new Exception(ex.Message);
        }
    }

    /// <summary>
    /// Logout user from api
    /// </summary>
    /// <param name="logoutDto"></param>
    /// <returns></returns>
    public async Task LogoutUserAsync(LogoutDTO logoutDto)
    {
        try
        {
            // Call the CognitoService to log out the user
            await _authenticationService.LogoutUserAsync(logoutDto.AccessToken);
            _logger.LogInformation($"User logged out successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to log out user. Exception occurred: {ex.Message}");
            throw new Exception(ex.Message);
        }
    }

    /// <summary>
    /// Confirms User with confirmation code
    /// </summary>
    /// <param name="confirmUserDto"></param>
    public async Task ConfirmUserAsync(ConfirmUserDTO confirmUserDto)
    {
        try
        {
            await _authenticationService.ConfirmUserAsync(confirmUserDto.Email, confirmUserDto.ConfirmationCode);
            _logger.LogInformation($"User {confirmUserDto.Email} confirmed successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to confirm user email. Exception occurred: {ex.Message}");
            throw new Exception(ex.Message);
        }
    }
    
    /// <summary>
    /// Resends confirmation code to confirm user email
    /// </summary>
    /// <param name="resendCodeDto"></param>
    public async Task ResendConfirmationCodeAsync(ResendCodeDTO resendCodeDto)
    {
        try
        {
            await _authenticationService.ResendConfirmationCodeAsync(resendCodeDto.Email);
            _logger.LogInformation($"User {resendCodeDto.Email} resent successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to resend confirmation code. Exception occurred: {ex.Message}");
            throw new Exception(ex.Message);
        }
    }

    /// <summary>
    /// Reset Refresh token
    /// </summary>
    /// <param name="refreshToken"></param>
    /// <returns></returns>
    public async Task<TokenResponseDTO> RefreshTokenAsync(RefreshTokenDTO refreshTokenDto)
    {
        try
        {
            return await _authenticationService.RefreshTokenAsync(refreshTokenDto.RefreshToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to refresh token. Exception occurred: {ex.Message}");
            throw new Exception(ex.Message);
        }
    }
}
