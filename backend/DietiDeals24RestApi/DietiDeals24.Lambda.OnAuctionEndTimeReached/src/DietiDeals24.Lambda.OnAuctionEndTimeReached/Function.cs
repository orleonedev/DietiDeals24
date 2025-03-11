using System.Text;
using System.Text.Json;
using Amazon.Lambda.Core;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace DietiDeals24.Lambda.OnAuctionEndTimeReached;

public class Function
{
    private static readonly HttpClient client = new HttpClient();

    public async Task<string> FunctionHandler(string input, ILambdaContext context)
    {
        try
        {
            // 🔹 Deserializziamo il JSON ricevuto
            var eventData = JsonSerializer.Deserialize<AuctionEvent>(input);

            if (eventData != null && !string.IsNullOrEmpty(eventData.AuctionId))
            {
                string auctionId = eventData.AuctionId;
                context.Logger.LogLine($"Auction {auctionId} has ended. Notifying backend...");
                var backendUrl = Environment.GetEnvironmentVariable("BACKEND_URL");
                 var payload = JsonSerializer.Serialize(new { auctionId = auctionId });
            var content = new StringContent(payload, Encoding.UTF8, "application/json");
            var response = await client.PostAsync(backendUrl, content);
            response.EnsureSuccessStatusCode();
            var responseString = await response.Content.ReadAsStringAsync();

            return $"Notification sent successfully. Response: {responseString}";
            }
            else
            {
                context.Logger.LogLine("Invalid event data received.");
            }
        }
        catch (Exception ex)
        {
            context.Logger.LogLine($"Error processing event: {ex.Message}");
        }
        
        return $"Error sending notification";
    }
}

public class AuctionEvent
{
    public string? AuctionId { get; set; }
}
