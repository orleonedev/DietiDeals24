using System.Text;
using System.Text.Json;
using Amazon.Lambda.Core;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace DietiDeals24.Lambda.OnAuctionEndTimeReached;

public class Function
{
    private static readonly HttpClient client = new HttpClient();

    public async Task<string> FunctionHandler(EventBridgeEvent input, ILambdaContext context)
    {
        var auctionId = input.Detail.AuctionId;
        var backendUrl = Environment.GetEnvironmentVariable("BACKEND_URL");

        try
        {
            var payload = JsonSerializer.Serialize(new { auctionId = auctionId, @event = "auctionExpired" });
            var content = new StringContent(payload, Encoding.UTF8, "application/json");
            var response = await client.PostAsync(backendUrl, content);
            response.EnsureSuccessStatusCode();
            var responseString = await response.Content.ReadAsStringAsync();

            return $"Notification sent successfully. Response: {responseString}";
        }
        catch (Exception ex)
        {
            context.Logger.LogLine($"Error sending notification: {ex.Message}");
            return $"Error sending notification: {ex.Message}";
        }
    }
}

public class EventBridgeEvent
{
    public Detail Detail { get; set; }
}

public class Detail
{
    public string AuctionId { get; set; }
}