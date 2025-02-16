using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Amazon.CognitoIdentityProvider;
using Amazon.CognitoIdentityProvider.Model;
using Amazon.Extensions.CognitoAuthentication;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class AuthenticationService: IAuthenticationService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IAmazonCognitoIdentityProvider _cognitoClient; // Cognito client for interacting with AWS Cognito
    private readonly ISecretsService _secretsService; // Service class to fetch secrets
    private readonly ILogger<AuthenticationService> _logger; // Logger for tracking events and errors

    // Constructor to initialize the service dependencies
    public AuthenticationService(
        IUnitOfWork unitOfWork,
        IAmazonCognitoIdentityProvider cognitoClient,
        ISecretsService secretsService,
        ILogger<AuthenticationService> logger
    )
    {
        _unitOfWork = unitOfWork;
        _cognitoClient = cognitoClient;
        _secretsService = secretsService;
        _logger = logger;
    }

    /// <summary>
    /// Creates a CognitoUserPool object using secrets from Secrets Manager.
    /// </summary>
    /// <returns></returns>
    private async Task<CognitoUserPool> GetCognitoUserPoolAsync()
    {
        var secrets = await _secretsService.GetSecretsAsync();
        return new CognitoUserPool(secrets["USER_POOL_ID"], secrets["COGNITO_CLIENT_ID"], _cognitoClient);
    }

    /// <summary>
    /// Validates input parameters
    /// </summary>
    /// <param name="inputs"></param>
    /// <exception cref="ArgumentException"></exception>
    private void ValidateRegistrationInput(params (string Value, string Name)[] inputs)
    {
        foreach (var (value, name) in inputs)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new ArgumentException($"{name} is required.", name);
            }
        }
    }

    /// <summary>
    /// Executes an asynchronous action with retry logic.
    /// </summary>
    /// <param name="action"></param>
    /// <param name="maxRetries"></param>
    /// <param name="delayMilliseconds"></param>
    private async Task<T> ExecuteWithRetryAsync<T>(Func<Task<T>> action, int maxRetries = 3, int delayMilliseconds = 2000)
    {
        int attempt = 0;

        while (true)
        {
            try
            {
                attempt++;
                return await action(); // Attempt to execute the action
            }
            catch (Exception ex) when (attempt < maxRetries)
            {
                _logger.LogWarning($"Attempt {attempt} failed: {ex.Message}. Retrying in {delayMilliseconds}ms...");
                await Task.Delay(delayMilliseconds); // Wait before retrying
            }
        }
    }
    
    //Overload with Task
    private async Task ExecuteWithRetryAsync(Func<Task> action, int maxRetries = 3, int delayMilliseconds = 2000)
    {
        int attempt = 0;

        while (true)
        {
            try
            {
                attempt++;
                await action(); // Attempt to execute the action
                return; // Success, exit method
            }
            catch (Exception ex) when (attempt < maxRetries)
            {
                _logger.LogWarning($"Attempt {attempt} failed: {ex.Message}. Retrying in {delayMilliseconds}ms...");
                await Task.Delay(delayMilliseconds); // Wait before retrying
            }
        }
    }

    /// <summary>
    /// Registers a new user in Cognito with the provided attributes.
    /// </summary>
    /// <param name="fullName"></param>
    /// <param name="username"></param>
    /// <param name="password"></param>
    /// <param name="email"></param>
    /// <param name="birthDate"></param>
    /// <returns></returns>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task<UserResponseDTO> RegisterUserAsync(RegistrationDTO registrationDto)
    {

        try
        {
            ValidateRegistrationInput(
                (registrationDto.FullName, nameof(registrationDto.FullName)),
                (registrationDto.Username, nameof(registrationDto.Username)),
                (registrationDto.Password, nameof(registrationDto.Password)),
                (registrationDto.Email, nameof(registrationDto.Email)),
                (registrationDto.BirthDate.ToString("yyyy-MM-dd"), nameof(registrationDto.BirthDate))
            );

            var dbUser = _unitOfWork.UserRepository.Get(u => u.Email == registrationDto.Email).FirstOrDefault();
            if (dbUser != null)
            {
                throw new UsernameExistsException("User already exists.");
            }
            
            var userPool = await GetCognitoUserPoolAsync();
            var attributes = new Dictionary<string, string>
            {
                { "name", registrationDto.FullName },
                { "preffered_username", registrationDto.Username },
                { "email", registrationDto.Email },
                { "birthdate", registrationDto.BirthDate.ToString("yyyy-MM-dd") } //MM months, mm minutes
            };
            
            await ExecuteWithRetryAsync(() =>
                userPool.SignUpAsync(registrationDto.Username, registrationDto.Password, attributes, null));
                
            var user = new User
            {
                CognitoSub = GetCognitoSub(registrationDto.Email).Result,
                Username = registrationDto.Username,
                Fullname = registrationDto.FullName,
                Email = registrationDto.Email,
                Role = UserRole.Buyer,
                BirthDate = registrationDto.BirthDate,
                HasVerifiedEmail = false
            };

            _unitOfWork.BeginTransaction();
            await _unitOfWork.UserRepository.Add(user);
            _unitOfWork.Commit();
            await _unitOfWork.Save();
            
            _logger.LogInformation($"User {registrationDto.Username} registered successfully.");
            
            return new UserResponseDTO
            {
                CognitoSub = user.CognitoSub,
                FullName = user.Fullname,
                Username = user.Username,
                Email = user.Email,
                IsEmailVerified = user.HasVerifiedEmail,
                BirthDate = user.BirthDate.ToString("yyyy-MM-dd")
            };
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex,$"Argument exception occured: {ex.Message}");
            throw new InvalidOperationException($"Argument exception occured: {ex.Message}");
        }
        catch (UsernameExistsException ex)
        {
            _logger.LogError($"Username {registrationDto.Username} already exists.", ex);
            throw new InvalidOperationException($"Username {registrationDto.Username} already exists.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to register user {registrationDto.Email}. {ex.Message}");
            throw new InvalidOperationException($"Failed to register user {registrationDto.Email}. {ex.Message}");
        }
    }

    /// <summary>
    /// Logs in a user with email and password, and returns authentication tokens.
    /// </summary>
    /// <param name="email"></param>
    /// <param name="password"></param>
    /// <returns></returns>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task<TokenResponseDTO> LoginUserAsync(string email, string password)
    {
        try
        {
            var userPool = await GetCognitoUserPoolAsync();
            var user = new CognitoUser(email, userPool.ClientID, userPool, _cognitoClient);

            var authRequest = new InitiateSrpAuthRequest
            {
                Password = password
            };

            var authResponse = await ExecuteWithRetryAsync(() => user.StartWithSrpAuthAsync(authRequest));
            _logger.LogInformation($"User {email} logged in successfully.");

            return new TokenResponseDTO
            {
                IdToken = authResponse.AuthenticationResult.IdToken,
                AccessToken = authResponse.AuthenticationResult.AccessToken,
                RefreshToken = authResponse.AuthenticationResult.RefreshToken
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to login user.");
            throw new InvalidOperationException($"Login failed: {ex.Message}", ex);
        }
    }
    
    /// <summary>
    /// Logout user
    /// </summary>
    /// <param name="accessToken"></param>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task LogoutUserAsync(string accessToken)
    {
        try
        {
            // Create the GlobalSignOut request
            var request = new GlobalSignOutRequest
            {
                AccessToken = accessToken
            };

            // Call GlobalSignOutAsync
            await _cognitoClient.GlobalSignOutAsync(request);
            _logger.LogInformation("User logged out successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to log out user.");
            throw new InvalidOperationException($"Logout failed: {ex.Message}", ex);
        }
    }

    /// <summary>
    /// Confirms a user's account using a confirmation code.
    /// </summary>
    /// <param name="email"></param>
    /// <param name="confirmationCode"></param>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task ConfirmUserAsync(string email, string confirmationCode)
    {
        try
        {
            var secrets = await _secretsService.GetSecretsAsync();
            var request = new ConfirmSignUpRequest
            {
                ClientId = secrets["COGNITO_CLIENT_ID"],
                Username = email,
                ConfirmationCode = confirmationCode
            };

            await ExecuteWithRetryAsync(() => _cognitoClient.ConfirmSignUpAsync(request));
            
            var dbUser = _unitOfWork.UserRepository.Get(u => u.Email == email).FirstOrDefault();
            if (dbUser == null)
            {
                throw new InvalidOperationException("User does not exists.");
            }
            dbUser.HasVerifiedEmail = true;
            
            _unitOfWork.BeginTransaction();
            await _unitOfWork.UserRepository.Update(dbUser);
            _unitOfWork.Commit();
            await _unitOfWork.Save();
            
            _logger.LogInformation($"User {email} confirmed successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Exception during confirming user: {ex.Message}");
            throw new InvalidOperationException($"Exception during confirming user: {ex.Message}", ex);
        }
    }

    /// <summary>
    /// Resends a confirmation code to the user's email.
    /// </summary>
    /// <param name="email"></param>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task ResendConfirmationCodeAsync(string email)
    {
        try
        {
            var user = await GetUserAsync(email);

            // Check if the email is already verified
            if (user.IsEmailVerified)
            {
                throw new InvalidOperationException("Email is already verified.");
            }

            // Retrieve secrets and resend confirmation code
            var secrets = await _secretsService.GetSecretsAsync();
            var request = new ResendConfirmationCodeRequest
            {
                ClientId = secrets["COGNITO_CLIENT_ID"],
                Username = email
            };

            await ExecuteWithRetryAsync(() => _cognitoClient.ResendConfirmationCodeAsync(request));
            _logger.LogInformation($"Confirmation code resent to {email}.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error resending confirmation code: {ex.Message}");
            throw new InvalidOperationException($"Error resending confirmation code: {ex.Message}", ex);
        }
    }
    
    /// <summary>
    /// Refresh token task
    /// </summary>
    /// <param name="refreshToken"></param>
    /// <returns></returns>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task<TokenResponseDTO> RefreshTokenAsync(string refreshToken)
    {
        try
        {
            var secrets = await _secretsService.GetSecretsAsync();
            var authRequest = new InitiateAuthRequest
            {
                AuthFlow = AuthFlowType.REFRESH_TOKEN_AUTH,
                ClientId = secrets["COGNITO_CLIENT_ID"],
                AuthParameters = new Dictionary<string, string>
                {
                    { "REFRESH_TOKEN", refreshToken }
                }
            };

            var response = await _cognitoClient.InitiateAuthAsync(authRequest);
            return new TokenResponseDTO
            {
                IdToken = response.AuthenticationResult.IdToken,
                AccessToken = response.AuthenticationResult.AccessToken,
                RefreshToken = response.AuthenticationResult.RefreshToken
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to refresh token.");
            throw new InvalidOperationException($"Refresh Token failed: {ex.Message}", ex);
        }
    }

    /// <summary>
    /// Gets single user from email
    /// </summary>
    /// <param name="email"></param>
    /// <returns></returns>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task<UserResponseDTO> GetUserAsync(string email)
    {
        try
        {
            var secrets = await _secretsService.GetSecretsAsync();

            var user = _cognitoClient.AdminGetUserAsync(new AdminGetUserRequest
            {
                Username = email,
                UserPoolId = secrets["USER_POOL_ID"]
            });

            var attributes = user.Result.UserAttributes
                .ToDictionary(attr => attr.Name, attr => attr.Value, StringComparer.OrdinalIgnoreCase);

            return new UserResponseDTO
            {
                FullName = attributes.GetValueOrDefault("name"),
                Username = attributes.GetValueOrDefault("preffered_username"),
                Email = attributes.GetValueOrDefault("email"),
                IsEmailVerified = bool.TryParse(attributes.GetValueOrDefault("email_verified"), out var isVerified) && isVerified,
                BirthDate = attributes.GetValueOrDefault("birthdate"),
            };
        }
        catch (UserNotFoundException ex)
        {
            _logger.LogError(ex, "User not found.");
            throw new InvalidOperationException($"User {email} not found.");
        }
    }
    
    /// <summary>
    /// Get Cognito Sub
    /// </summary>
    /// <param name="email"></param>
    /// <returns></returns>
    /// <exception cref="Exception"></exception>
    public async Task<string> GetCognitoSub(string email)
    {
        var secrets = await _secretsService.GetSecretsAsync();

        try
        {
            // Fetch the user from Cognito
            var request = new AdminGetUserRequest
            {
                Username = email,
                UserPoolId = secrets["USER_POOL_ID"]
            };

            var response = await _cognitoClient.AdminGetUserAsync(request);

            // Extract the CognitoSub (sub) attribute
            var subAttribute = response.UserAttributes.FirstOrDefault(attr => attr.Name == "sub");
            return subAttribute?.Value;
        }
        catch (Exception ex)
        { 
            _logger.LogError(ex, "Failed to get cognito sub.");
            throw new InvalidOperationException($"Cognito sub attribute not found: {ex.Message}");
        }
    }
}