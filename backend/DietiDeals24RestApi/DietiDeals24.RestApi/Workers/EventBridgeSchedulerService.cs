using Amazon.Scheduler;
using Amazon.Scheduler.Model;

namespace DietiDeals24.RestApi.Workers;

public class EventBridgeSchedulerService
{
    private readonly AmazonSchedulerClient _schedulerClient;

    public EventBridgeSchedulerService()
    {
        _schedulerClient = new AmazonSchedulerClient();
    }

    public async Task<bool> ScheduleAuctionEndEvent(string auctionId, DateTime endTime)
    {
        string scheduleName = $"AuctionEnd-{auctionId}";

        var request = new CreateScheduleRequest
        {
            Name = scheduleName,
            FlexibleTimeWindow = new FlexibleTimeWindow { Mode = FlexibleTimeWindowMode.OFF },
            ScheduleExpression = $"at({endTime:yyyy-MM-dd'T'HH:mm:ss'Z'})",
            Target = new Target
            {
                Arn = Environment.GetEnvironmentVariable("ARN_LAMBDA_AUCTION_END_TIME"),
                RoleArn = Environment.GetEnvironmentVariable("ARN_AUCTION_END_TIME_ROLE"),

                // 🔹 Passiamo il JSON con l'ID dell'asta come payload alla Lambda
                Input = $"{{ \"auctionId\": \"{auctionId}\" }}"
            }
        };

        try
        {
            await _schedulerClient.CreateScheduleAsync(request);
            return true;
        }
        catch (Exception ex)
        {
            return false;
        }
    }
    
    public async Task DeleteScheduledAuctionEndEvent(string auctionId)
    {
        string scheduleName = $"AuctionEnd-{auctionId}"; // Stesso nome assegnato prima

        var request = new DeleteScheduleRequest
        {
            Name = scheduleName
        };

        await _schedulerClient.DeleteScheduleAsync(request);
    }
}