using System;

namespace DietiDeals24.DataAccessLayer.Entities;

public class UserPushToken
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string DeviceToken { get; set; }
    public string EndPointArn { get; set; }
    public DateTime RegistrationDate { get; set; }

    // Navigation Properties
    public User User { get; set; }
}
