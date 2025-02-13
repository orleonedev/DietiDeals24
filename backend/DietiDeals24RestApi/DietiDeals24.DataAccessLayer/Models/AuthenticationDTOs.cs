using System;

namespace DietiDeals24.DataAccessLayer.Models;

public class LoginDTO
{
    public string Email { get; set; }
    public string Password { get; set; }
}

public class RegistrationDTO
{
    public string FullName { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public string Password { get; set; }
    public DateTime BirthDate { get; set; }
    public string Gender { get; set; }
}

public class UserResponseDTO
{
    public string FullName { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public bool IsEmailVerified { get; set; }
    public string BirthDate { get; set; }
    public string Gender { get; set; }
}

public class ConfirmUserDTO
{
    public string Email { get; set; }
    public string ConfirmationCode { get; set; }
}

public class ResendCodeDTO
{
    public string Email { get; set; }
}

public class TokenResponseDTO
{
    public string IdToken { get; set; }
    public string AccessToken { get; set; }
    public string RefreshToken { get; set; }
}

public class RefreshTokenDTO
{
    public string RefreshToken { get; set; }
}

public class LogoutDTO
{
    public string AccessToken { get; set; }
}