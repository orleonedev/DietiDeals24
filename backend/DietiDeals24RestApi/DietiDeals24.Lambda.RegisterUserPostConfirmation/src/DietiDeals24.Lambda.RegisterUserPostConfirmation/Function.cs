using Amazon.Lambda.Core;
using Amazon.Lambda.Core;
using Newtonsoft.Json;
using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace DietiDeals24.Lambda.RegisterUserPostConfirmation;

public class Function
{
    private static readonly HttpClient HttpClient = new HttpClient();
    
    public async Task<object> FunctionHandler(object input, ILambdaContext context)
    {
        context.Logger.LogLine("Received Cognito PostConfirmation event.");

        // Convertiamo l'input in un oggetto JSON
        var jsonString = JsonConvert.SerializeObject(input);
        dynamic eventData = JsonConvert.DeserializeObject(jsonString);
        
        // Estrarre i dati dell'utente dal payload Cognito
        string userId = eventData?.request?.userAttributes?.sub;
        string username = eventData?.request?.userAttributes?.preferred_username ?? eventData?.userName;
        string fullName = eventData?.request?.userAttributes?.name;
        string email = eventData?.request?.userAttributes?.email;
        string birthdate = eventData?.request?.userAttributes?.birthdate;
        string role = eventData?.request?.userAttributes?["custom:role"]; // Attributo custom

        // Crea l'oggetto JSON per il backend
        var userPayload = new
        {
            Id = userId,
            Username = username,
            FullName = fullName,
            Email = email,
            Birthdate = birthdate,
            Role = role,
            HasVerifiedEmail = true // Questo valore è sempre true in Cognito
        };

        // URL del backend (da aggiornare con l'indirizzo reale quando disponibile)
        string backendUrl = "http://your-backend-url/api/users";

        var requestContent = new StringContent(JsonConvert.SerializeObject(userPayload), Encoding.UTF8, "application/json");

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

        return eventData;
    }
}
