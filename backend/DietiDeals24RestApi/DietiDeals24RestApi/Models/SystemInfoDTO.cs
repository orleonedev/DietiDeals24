namespace DietiDeals24RestApi.Models;

public class SystemInfoDTO
{
    public string? ApplicationVersion { get; set; }
    
    public string? MachineName { get; set; }
    
    public string? OSVersion { get; set; }
    
    public DateTime? CurrentDateTime { get; set; }
}