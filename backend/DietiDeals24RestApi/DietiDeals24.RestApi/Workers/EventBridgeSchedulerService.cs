using Amazon.Scheduler;
using Amazon.Scheduler.Model;

namespace DietiDeals24.RestApi.Workers;

public class EventBridgeSchedulerService
{
    private readonly AmazonSchedulerClient _schedulerClient;
    private readonly ILogger<EventBridgeSchedulerService> _logger;

    public EventBridgeSchedulerService(ILogger<EventBridgeSchedulerService> logger)
    {
        _logger = logger;
        _schedulerClient = new AmazonSchedulerClient();
    }

    public async Task<bool> ScheduleAuctionEndEvent(string auctionId, DateTime endTime)
    {
        string scheduleName = $"AuctionEnd-{auctionId}";
        _logger.LogInformation($"[ EventBridgeSchedulerService] Scheduling AuctionEnd {scheduleName}");
        var request = new CreateScheduleRequest
        {
            Name = scheduleName,
            FlexibleTimeWindow = new FlexibleTimeWindow { Mode = FlexibleTimeWindowMode.OFF },
            ScheduleExpression = $"at({endTime:yyyy-MM-ddTHH:mm:ss})",
            Target = new Target
            {
                Arn = Environment.GetEnvironmentVariable("ARN_LAMBDA_AUCTION_END_TIME"),
                RoleArn = Environment.GetEnvironmentVariable("ARN_AUCTION_END_TIME_ROLE"),

                // 🔹 Passiamo il JSON con l'ID dell'asta come payload alla Lambda
                Input = $"{{ \"auctionId\": \"{auctionId}\" }}"
            }
        };
        _logger.LogInformation($"[ EventBridgeSchedulerService] Scheduling AuctionEnd {scheduleName} -> request {request}");
        try
        {
            await _schedulerClient.CreateScheduleAsync(request);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[ EventBridgeSchedulerService] Scheduling AuctionEnd {scheduleName} failed with message: {ex.Message}");
            return false;
        }
    }
    
    public async Task DeleteScheduledAuctionEndEvent(string auctionId)
    {
        string scheduleName = $"AuctionEnd-{auctionId}"; // Stesso nome assegnato prima
        _logger.LogInformation($"[ EventBridgeSchedulerService ] Deleting Schedule AuctionEnd {scheduleName}");
        var request = new DeleteScheduleRequest
        {
            Name = scheduleName
        };

        var response = await _schedulerClient.DeleteScheduleAsync(request);
        _logger.LogInformation($"[ EventBridgeSchedulerService ] Status: { response.HttpStatusCode } Deleting Schedule AuctionEnd {scheduleName}");
    }
}