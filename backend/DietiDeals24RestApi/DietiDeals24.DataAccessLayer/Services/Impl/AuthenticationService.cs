using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Amazon.CognitoIdentityProvider;
using Amazon.CognitoIdentityProvider.Model;
using Amazon.Extensions.CognitoAuthentication;
using DietiDeals24.DataAccessLayer.Models;
using Microsoft.Extensions.Logging;

namespace DietiDeals24.DataAccessLayer.Services.Impl;

public class AuthenticationService: IAuthenticationService
{
    private readonly IAmazonCognitoIdentityProvider _cognitoClient; // Cognito client for interacting with AWS Cognito
    private readonly ISecretsService _secretsService; // Service class to fetch secrets from AWS Secrets Manager
    private readonly ILogger<AuthenticationService> _logger; // Logger for tracking events and errors

    // Constructor to initialize the service dependencies
    public AuthenticationService(
        IAmazonCognitoIdentityProvider cognitoClient,
        ISecretsService secretsService,
        ILogger<AuthenticationService> logger
    )
    {
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
    /// Validates input parameters for user registration.
    /// </summary>
    /// <param name="fullName"></param>
    /// <param name="username"></param>
    /// <param name="password"></param>
    /// <param name="email"></param>
    /// <param name="birthDate"></param>
    /// <param name="gender"></param>
    /// <exception cref="ArgumentException"></exception>
    private void ValidateRegistrationInput(string fullName, string username, string password, string email, string birthDate, string gender)
    {
        if (string.IsNullOrWhiteSpace(fullName)) throw new ArgumentException("Full name is required.", nameof(fullName));
        if (string.IsNullOrWhiteSpace(username)) throw new ArgumentException("Username is required.", nameof(username));
        if (string.IsNullOrWhiteSpace(password)) throw new ArgumentException("Password is required.", nameof(password));
        if (string.IsNullOrWhiteSpace(email)) throw new ArgumentException("Email is required.", nameof(email));
        if (string.IsNullOrWhiteSpace(birthDate)) throw new ArgumentException("Birth date is required.", nameof(birthDate));
        if (string.IsNullOrWhiteSpace(gender)) throw new ArgumentException("Gender is required.", nameof(gender));
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
            catch
            {
                throw; // Let the exception propagate if retries are exhausted
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
    /// <param name="gender"></param>
    /// <returns></returns>
    /// <exception cref="InvalidOperationException"></exception>
    public async Task<AdminGetUserResponse> RegisterUserAsync(string fullName, string username, string password, string email, string birthDate, string gender)
    {
        ValidateRegistrationInput(fullName, username, password, email, birthDate, gender);

        try
        {
            var userPool = await GetCognitoUserPoolAsync();
            var attributes = new Dictionary<string, string>
            {
                { "name", fullName },
                { "nickname", username },
                { "email", email },
                { "birthdate", birthDate },
                { "gender", gender }
            };

            await ExecuteWithRetryAsync(() => userPool.SignUpAsync(username, password, attributes, null));
            _logger.LogInformation($"User {username} registered successfully.");
            return GetUserAsync(email).Result;
        }
        catch (UsernameExistsException)
        {
            throw new InvalidOperationException("The username is already taken. Please try a different one.");
        }
        catch (InvalidPasswordException)
        {
            throw new InvalidOperationException("The password does not meet the complexity requirements.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to register user.");
            throw new InvalidOperationException($"Registration failed: {ex.Message}", ex);
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
    public async Task<HttpStatusCode> ConfirmUserAsync(string email, string confirmationCode)
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

            var response = await ExecuteWithRetryAsync(() => _cognitoClient.ConfirmSignUpAsync(request));
            if (response.HttpStatusCode == System.Net.HttpStatusCode.OK)
            {
                _logger.LogInformation($"User {email} confirmed successfully.");
            }
            else
            {
                _logger.LogError($"User {email} confirmation code {confirmationCode} failed.");
            }
            return response.HttpStatusCode;
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
            if (user == null)
            {
                throw new InvalidOperationException("No user found.");
            }

            // Check if the email is already verified
            var isEmailVerified = user.UserAttributes
                .FirstOrDefault(attr => string.Equals(attr.Name, "email_verified", StringComparison.OrdinalIgnoreCase))
                ?.Value;

            if (string.Equals(isEmailVerified, "true", StringComparison.OrdinalIgnoreCase))
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
    /// Gets single user from email
    /// </summary>
    /// <param name="email"></param>
    /// <returns></returns>
    public async Task<AdminGetUserResponse> GetUserAsync(string email)
    {
        var secrets = await _secretsService.GetSecretsAsync();
        
        var response = _cognitoClient.AdminGetUserAsync(new AdminGetUserRequest
        {
            Username = email,
            UserPoolId = secrets["USER_POOL_ID"]
        });

        return response.Result;
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
            return subAttribute?.Value ?? throw new Exception("Cognito sub attribute not found.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error fetching user: {ex.Message}");
            throw;
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
                RefreshToken = refreshToken
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to refresh token.");
            throw new InvalidOperationException($"Refresh Token failed: {ex.Message}", ex);
        }
    }
}