using System.Text;
using System.Text.Json;
using Amazon.Lambda.Core;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace DietiDeals24.Lambda.OnAuctionEndTimeReached;

public class Function
{
    private static readonly HttpClient client = new HttpClient();

    public async Task FunctionHandler(AuctionEvent input, ILambdaContext context)
    {
        try
        {

            if (!string.IsNullOrEmpty(input.auctionId))
            {
                string auctionId = input.auctionId;
                context.Logger.LogLine($"Auction {auctionId} has ended. Notifying backend...");
                var backendUrl = Environment.GetEnvironmentVariable("BACKEND_URL");
                var content = new StringContent($"\"{auctionId}\"", Encoding.UTF8, "application/json");
                var response = await client.PostAsync(backendUrl, content);
                response.EnsureSuccessStatusCode();
                var responseString = await response.Content.ReadAsStringAsync();
                context.Logger.LogLine($"Notification sent successfully. Response: {responseString}");
            }
            else
            {
                context.Logger.LogLine($"[ ERROR ] Invalid event data received auction ID: {input.auctionId}.");
            }
        }
        catch (Exception ex)
        {
            context.Logger.LogLine($"[ ERROR ] Error processing event: {ex.Message}");
        }
        
    }
}

public class AuctionEvent
{
    public string? auctionId { get; set; }
}
