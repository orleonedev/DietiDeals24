using System.Net;
using Amazon.CognitoIdentityProvider.Model;
using DietiDeals24.DataAccessLayer.Services;
using DietiDeals24.RestApi.Models;

namespace DietiDeals24.RestApi.Workers.Impl;

public class AuthenticationWorker: IAuthenticationWorker
{
    private readonly IAuthenticationService _authenticationService; // Interfaccia per Cognito
    //private readonly IRepository<> _repository; // Repository per il database locale

    public AuthenticationWorker(
        IAuthenticationService authenticationService/*,
        UserRepository repository*/)
    {
        _authenticationService = authenticationService;
        //_repository = repository;
    }

    /// <summary>
    /// Registers user and the save the data in the repository
    /// </summary>
    /// <param name="registrationDto"></param>
    public async Task<AdminGetUserResponse> RegisterUserAsync(RegistrationDTO registrationDto)
    {
        // Step 1: Registra l'utente in Cognito
        var user = await _authenticationService.RegisterUserAsync(
            registrationDto.FullName,
            registrationDto.Username,
            registrationDto.Password,
            registrationDto.Email,
            registrationDto.BirthDate,
            registrationDto.Gender
        );

        // Step 2: Salva i dettagli dell'utente nel database locale
        /*await _repository.SaveUserAsync(new User
        {
            FullName = registrationDto.FullName,
            Username = registrationDto.Username,
            Email = registrationDto.Email,
            BirthDate = registrationDto.BirthDate,
            Gender = registrationDto.Gender,
            CreatedAt = DateTime.UtcNow
        });*/

        return user;
    }

    /// <summary>
    /// Login user and updates cognito sub if is missing
    /// </summary>
    /// <param name="email"></param>
    /// <param name="password"></param>
    /// <returns></returns>
    public async Task<TokenResponseDTO> LoginUserAsync(string email, string password)
    {
        // Step 1: Esegui il login
        var token = await _authenticationService.LoginUserAsync(email, password);

        // Step 2: Recupera il CognitoSub dall'account
        var cognitoSub = await _authenticationService.GetCognitoSub(email);

        // Step 3: Aggiorna il database locale con il CognitoSub (se non esistente)
        /*var user = await _userRepository.GetUserByEmailAsync(email);
        if (user != null && string.IsNullOrEmpty(user.CognitoSub))
        {
            user.CognitoSub = cognitoSub;
            await _userRepository.UpdateUserAsync(user);
        }*/

        return new TokenResponseDTO
        {
            IdToken = token.IdToken,
            AccessToken = token.AccessToken,
            RefreshToken = token.RefreshToken
        };
    }

    /// <summary>
    /// Confirms User with confirmation code
    /// </summary>
    /// <param name="confirmUserDto"></param>
    public async Task<string> ConfirmUserAsync(ConfirmUserDTO confirmUserDto)
    {
        var response = await _authenticationService.ConfirmUserAsync(confirmUserDto.Email, confirmUserDto.ConfirmationCode);

        if (response == HttpStatusCode.OK)
        {
            return ($"User {confirmUserDto.Email} confirmed successfully.");
        }
        else
        {
            return ($"User {confirmUserDto.Email} confirmation code {confirmUserDto.ConfirmationCode} failed.");
        }
    }

    /// <summary>
    /// Reset Refresh token
    /// </summary>
    /// <param name="refreshToken"></param>
    /// <returns></returns>
    public async Task<TokenResponseDTO> RefreshTokenAsync(string refreshToken)
    {
        var token = await _authenticationService.RefreshTokenAsync(refreshToken);

        return new TokenResponseDTO
        {
            IdToken = token.IdToken,
            AccessToken = token.AccessToken,
            RefreshToken = token.RefreshToken
        };
    }
}
