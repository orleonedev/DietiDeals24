namespace DietiDeals24.RestApi.Models;

public class PushNotificationTemplate
{
    public const string IOSGeneric = "{ \"aps\" : {\"alert\" : \"Push Test Title\"} }";

    public static string GetPushString( string titleKey, string messageKey , string auctionTitle, Guid auctionID)
    {
        return $"{{ \"aps\" : {{ \"alert\" : {{ \"title-loc-key\" : \"{titleKey}\", \"subtitle\" : \"{auctionTitle}\", \"loc-key\" : \"{messageKey}\" }}, \"sound\" : \"default\" }}, \"data\" : {{ \"auctionId\" : \"{auctionID}\"}} }}";
    }
}