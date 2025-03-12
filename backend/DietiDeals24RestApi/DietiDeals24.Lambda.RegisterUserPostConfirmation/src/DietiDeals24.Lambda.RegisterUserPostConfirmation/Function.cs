using Amazon.Lambda.Core;
using Newtonsoft.Json;
using System.Text;
using System.Threading.Tasks;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace DietiDeals24.Lambda.RegisterUserPostConfirmation;

public class Function
{
    private static readonly HttpClient HttpClient = new HttpClient();
    
    public async Task<object> FunctionHandler(CognitoPostConfirmationEvent input, ILambdaContext context)
    {
        context.Logger.LogLine("Received Cognito PostConfirmation event.");
        
        // Access properties using the strongly typed object
        Guid userId = input.request.userAttributes.sub; 
        string username = input.request.userAttributes.preferred_username;
        string fullName = input.request.userAttributes.name;
        string email = input.request.userAttributes.email;
        string birthdate = input.request.userAttributes.birthdate;

        var registrationDTO = new RegistrationDTO
        {
            CognitoSub = userId,
            FullName = fullName,
            Username = username,
            Email = email,
            BirthDate = DateOnly.Parse(birthdate).ToDateTime(TimeOnly.MinValue, DateTimeKind.Unspecified)
        };

        var backendUrl = Environment.GetEnvironmentVariable("BACKEND_URL");

        var requestContent = new StringContent(JsonConvert.SerializeObject(registrationDTO), Encoding.UTF8, "application/json");

        try
        {
            HttpResponseMessage response = await HttpClient.PostAsync(backendUrl, requestContent);

            if (response.IsSuccessStatusCode)
            {
                context.Logger.LogLine("User successfully created in backend.");
                
            }
            else
            {
                context.Logger.LogLine($"Error: {response.StatusCode}, {await response.Content.ReadAsStringAsync()}");
            }
        }
        catch (Exception ex)
        {
            context.Logger.LogLine($"Exception: {ex.Message}");
        }

        input.version = "1";
        return input;
    }
}

public class CognitoPostConfirmationEvent
{
    public string version { get; set; }
    public string region { get; set; }
    public string userPoolId { get; set; }
    public string triggerSource { get; set; }
    public string userName { get; set; }
    public Request request { get; set; }
    public Response response { get; set; }
}

public class UserAttributes
{
    public Guid sub { get; set; }
    public string preferred_username { get; set; }
    public string name { get; set; }
    public string email { get; set; }
    public string birthdate { get; set; }
}

public class Request
{
    public UserAttributes userAttributes { get; set; }
}

public class Response
{
}

public class RegistrationDTO
{
    public Guid CognitoSub { get; set; }
    public string FullName { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public DateTime BirthDate { get; set; }
}