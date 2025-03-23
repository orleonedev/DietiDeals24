using Amazon.SimpleNotificationService;
using Amazon.SimpleNotificationService.Model;
using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;
using DietiDeals24.RestApi.Workers;
using DietiDeals24.RestApi.Workers.Impl;
using Microsoft.Extensions.Logging;
using Moq;
using Range = Moq.Range;

namespace DietiDeals24.RestApi.Test;

public class NotificationWorkerTests
{
    [Collection("Sequential")]
    public class AddNotificationTokenAsyncTests // Black e White Box
    {
        private static Guid GetValidUserId()
        {
            return Guid.NewGuid();
        }

        private static string GetValidDeviceToken()
        {
            return "359015081997370";
        }

        public class BlackBoxTests
        {
            private readonly NotificationWorker _notificationWorker;

            public BlackBoxTests()
            {
                var mockLogger = new Mock<ILogger<NotificationWorker>>();
                var mockNotificationService = new Mock<INotificationService>();
                var mockNotificationClient = new Mock<IAmazonSimpleNotificationService>();
                mockNotificationClient.Setup(client =>
                        client.CreatePlatformEndpointAsync(It.IsAny<CreatePlatformEndpointRequest>(),
                            It.IsAny<CancellationToken>()))
                    .ReturnsAsync(new CreatePlatformEndpointResponse
                        { EndpointArn = "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone" });
                _notificationWorker = new NotificationWorker(mockLogger.Object,
                    mockNotificationService.Object,
                    mockNotificationClient.Object);
            }

            [Fact]
            public async Task AddNotificationTokenAsync_TestWithValidInput()
            {
                // Arrange
                var userId = GetValidUserId();
                var deviceToken = GetValidDeviceToken();

                //Act
                var result = _notificationWorker.AddNotificationTokenAsync(userId, deviceToken);
                await result;

                //Assert
                Assert.True(result.IsCompletedSuccessfully);
            }

            [Fact]
            public async Task AddNotificationTokenAsync_TestWithEmptyUserId()
            {
                // Arrange
                var userId = Guid.Empty;
                var deviceToken = GetValidDeviceToken();

                // Act & Assert
                await Assert.ThrowsAsync<Exception>(() =>
                    _notificationWorker.AddNotificationTokenAsync(userId, deviceToken));
            }

            [Fact]
            public async Task AddNotificationTokenAsync_TestWithEmptyDeviceToken()
            {
                // Arrange
                var userId = GetValidUserId();
                var deviceToken = "";

                // Act & Assert
                await Assert.ThrowsAsync<Exception>(() =>
                    _notificationWorker.AddNotificationTokenAsync(userId, deviceToken));
            }

            [Fact]
            public async Task AddNotificationTokenAsync_TestWithNullDeviceToken()
            {
                // Arrange
                var userId = GetValidUserId();
                string deviceToken = null;

                //Act & Assert
                await Assert.ThrowsAsync<Exception>(() =>
                    _notificationWorker.AddNotificationTokenAsync(userId, deviceToken));
            }

            [Fact]
            public async Task AddNotificationTokenAsync_TestWithLongDeviceToken()
            {
                // Arrange
                var userId = GetValidUserId();
                var deviceToken = new string('a', 300);

                //Act
                var result = _notificationWorker.AddNotificationTokenAsync(userId, deviceToken);
                await result;

                //Assert
                Assert.True(result.IsCompletedSuccessfully);
            }
        }

        public class WhiteBoxTests
        {
            private readonly NotificationWorker _notificationWorker;
            private readonly Mock<ILogger<NotificationWorker>> _mockLogger;
            private readonly Mock<INotificationService> _mockNotificationService;
            private readonly Mock<IAmazonSimpleNotificationService> _mockNotificationClient;

            public WhiteBoxTests()
            {
                _mockLogger = new Mock<ILogger<NotificationWorker>>();
                _mockNotificationService = new Mock<INotificationService>();
                _mockNotificationClient = new Mock<IAmazonSimpleNotificationService>();
                _notificationWorker = new NotificationWorker(_mockLogger.Object,
                    _mockNotificationService.Object,
                    _mockNotificationClient.Object);
            }

            [Fact]
            public async Task TestPath_1_2_3_4_5_Success()
            {
                //Arrange
                var userId = GetValidUserId();
                var deviceToken = GetValidDeviceToken();
                var endpointArn = "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone";

                _mockNotificationService.Setup(s => s.GetEndPointArnFromDeviceTokenAsync(deviceToken));
                _mockNotificationClient.Setup(client =>
                        client.CreatePlatformEndpointAsync(It.IsAny<CreatePlatformEndpointRequest>(),
                            It.IsAny<CancellationToken>()))
                    .ReturnsAsync(new CreatePlatformEndpointResponse
                        { EndpointArn = endpointArn });
                _mockNotificationService.Setup(s => s.AddNotificationTokenAsync(userId, deviceToken,
                        endpointArn))
                    .ReturnsAsync(new UserPushToken());

                //Act
                await _notificationWorker.AddNotificationTokenAsync(userId, deviceToken);

                //Assert
                _mockLogger.Verify(
                    x => x.Log(
                        LogLevel.Information,
                        It.IsAny<EventId>(),
                        It.IsAny<It.IsAnyType>(),
                        It.IsAny<Exception>(),
                        (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                    Times.Exactly(3));
                _mockNotificationService.Verify(s => s.GetEndPointArnFromDeviceTokenAsync(deviceToken), Times.Once);
                _mockNotificationClient.Verify(client => client.CreatePlatformEndpointAsync(
                    It.Is<CreatePlatformEndpointRequest>(req => req.Token == deviceToken),
                    It.IsAny<CancellationToken>()
                ), Times.Once);
                _mockNotificationService.Verify(
                    s => s.AddNotificationTokenAsync(userId, deviceToken,
                        endpointArn), Times.Once);
            }

            [Fact]
            public async Task TestPath1_2_3_4_5_Exception()
            {
                
                //Arrange
                var userId = GetValidUserId();
                var deviceToken = GetValidDeviceToken();
                var endpointArn = "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone";
                var exception = new Exception("AddNotificationTokenAsync Exception.");

                _mockNotificationService.Setup(s => s.GetEndPointArnFromDeviceTokenAsync(deviceToken));
                _mockNotificationClient.Setup(client =>
                        client.CreatePlatformEndpointAsync(It.IsAny<CreatePlatformEndpointRequest>(),
                            It.IsAny<CancellationToken>()))
                    .ReturnsAsync(new CreatePlatformEndpointResponse
                        { EndpointArn = endpointArn });
                _mockNotificationService.Setup(s => s.AddNotificationTokenAsync(userId, deviceToken,
                        endpointArn))
                    .ThrowsAsync(exception);

                //Act
                await Assert.ThrowsAsync<Exception>(() =>
                    _notificationWorker.AddNotificationTokenAsync(userId, deviceToken));

                //Assert
                _mockLogger.Verify(
                    x => x.Log(
                        LogLevel.Error,
                        It.IsAny<EventId>(),
                        It.IsAny<It.IsAnyType>(),
                        It.IsAny<Exception>(),
                        (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                    Times.AtLeastOnce);
                _mockNotificationService.Verify(s => s.GetEndPointArnFromDeviceTokenAsync(deviceToken), Times.Once);
                _mockNotificationClient.Verify(client => client.CreatePlatformEndpointAsync(
                    It.Is<CreatePlatformEndpointRequest>(req => req.Token == deviceToken),
                    It.IsAny<CancellationToken>()
                ), Times.Once);
                _mockNotificationService.Verify(
                    s => s.AddNotificationTokenAsync(userId, deviceToken,
                        endpointArn), Times.Once);
            }

            [Fact]
            public async Task TestPath_1_2_3_4()
            {
                //Arrange
                var userId = GetValidUserId();
                var deviceToken = GetValidDeviceToken();
                var exception = new Exception("CreatePlatformEndpoint Exception.");
                
                _mockNotificationService.Setup(s => s.GetEndPointArnFromDeviceTokenAsync(deviceToken));
                _mockNotificationClient.Setup(client =>
                        client.CreatePlatformEndpointAsync(It.IsAny<CreatePlatformEndpointRequest>(),
                            It.IsAny<CancellationToken>()))
                    .ThrowsAsync(exception);
                
                //Act
                await Assert.ThrowsAsync<Exception>(() =>
                    _notificationWorker.AddNotificationTokenAsync(userId, deviceToken));
                
                //Assert
                _mockLogger.Verify(
                    x => x.Log(
                        LogLevel.Error,
                        It.IsAny<EventId>(),
                        It.IsAny<It.IsAnyType>(),
                        It.IsAny<Exception>(),
                        (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                    Times.AtLeastOnce);
                _mockNotificationService.Verify(s => s.GetEndPointArnFromDeviceTokenAsync(deviceToken), Times.Once);
                _mockNotificationClient.Verify(client => client.CreatePlatformEndpointAsync(
                    It.Is<CreatePlatformEndpointRequest>(req => req.Token == deviceToken),
                    It.IsAny<CancellationToken>()
                ), Times.Once);
                _mockNotificationService.Verify(
                    s => s.AddNotificationTokenAsync(userId, deviceToken,
                        It.IsAny<string>()), Times.Never);
            }

            [Fact]
            public async Task TestPath_1_2_3_6()
            {
                //Arrange
                var userId = GetValidUserId();
                var deviceToken = GetValidDeviceToken();
                var alreadyRegisteredArn = "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone";

                _mockNotificationService.Setup(s => s.GetEndPointArnFromDeviceTokenAsync(deviceToken))
                    .ReturnsAsync(alreadyRegisteredArn);
                
                //Act
                await _notificationWorker.AddNotificationTokenAsync(userId, deviceToken);
                
                // Assert
                _mockLogger.Verify(l => l.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.Is<It.IsAnyType>((state, type) => state.ToString().Contains($"[WORKER] Adding notification token failed for user {userId}: Device token {deviceToken} was already registered.")),
                    It.IsAny<Exception>(),
                    (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()
                ), Times.Once);
                _mockNotificationService.Verify(
                    s => s.AddNotificationTokenAsync(userId, deviceToken, alreadyRegisteredArn), 
                    Times.Never
                );
            }
        }

        [Collection("Sequential")]
        public class SendNotificationAsyncTests // Black e White Box test
        {
            private static NotificationDTO CreateTestNotificationDto()
            {
                return new NotificationDTO
                {
                    Type = NotificationType.AuctionClosed,
                    Message = "L'asta è terminata.",
                    AuctionId = Guid.NewGuid(),
                    AuctionTitle = "iPhone 12 - Usato"
                };
            }

            private static Guid GetValidUserId()
            {
                return Guid.NewGuid();
            }

            public class BlackBoxTests
            {
                private readonly NotificationWorker _notificationWorker;
                private readonly Mock<ILogger<NotificationWorker>> _mockLogger;
                private readonly Mock<INotificationService> _mockNotificationService;
                private readonly Mock<IAmazonSimpleNotificationService> _mockSnsClient;

                public BlackBoxTests()
                {
                    _mockLogger = new Mock<ILogger<NotificationWorker>>();
                    _mockNotificationService = new Mock<INotificationService>();
                    _mockSnsClient = new Mock<IAmazonSimpleNotificationService>();
                    _notificationWorker = new NotificationWorker(_mockLogger.Object,
                        _mockNotificationService.Object,
                        _mockSnsClient.Object);
                }

                [Fact]
                public async Task SendNotificationAsync_TestWithValidInput()
                {
                    //Arrange
                    var userId = Guid.NewGuid();
                    var notificationDto = CreateTestNotificationDto();

                    //Act
                    var result = _notificationWorker.SendNotificationAsync(userId, notificationDto);
                    await result;

                    //Assert
                    Assert.True(result.IsCompletedSuccessfully);
                }

                [Fact]
                public async Task SendNotificationAsync_TestWithMinNotificationDto_ValidUserId()
                {
                    //Arrange
                    var userId = Guid.NewGuid();
                    var notificationDto = new NotificationDTO
                    {
                        Id = default,
                        Type = NotificationType.AuctionClosed,
                        CreationDate = default,
                        Message = "",
                        MainImageUrl = "",
                        AuctionId = default,
                        AuctionTitle = ""
                    };

                    //Act
                    var result = _notificationWorker.SendNotificationAsync(userId, notificationDto);
                    await result;

                    //Assert
                    Assert.True(result.IsCompletedSuccessfully);
                }

                [Fact]
                public async Task SendNotificationAsync_TestWithMaxNotificationDto_ValidUserId()
                {
                    //Arrange
                    var userId = Guid.NewGuid();
                    var notificationDto = new NotificationDTO
                    {
                        Id = default,
                        Type = NotificationType.AuctionBid,
                        CreationDate = default,
                        Message = new string('a', 300),
                        MainImageUrl = new string('a', 300),
                        AuctionId = default,
                        AuctionTitle = new string('a', 300)
                    };

                    //Act
                    var result = _notificationWorker.SendNotificationAsync(userId, notificationDto);
                    await result;

                    //Assert
                    Assert.True(result.IsCompletedSuccessfully);
                }

                [Fact]
                public async Task SendNotificationAsync_TestWithEmptyUserId_ValidNotificationDto()
                {
                    //Arrange
                    var userId = Guid.Empty;
                    var notificationDto = CreateTestNotificationDto();

                    //Act & Assert
                    await Assert.ThrowsAsync<Exception>(() =>
                        _notificationWorker.SendNotificationAsync(userId, notificationDto));

                }

                [Fact]
                public async Task SendNotificationAsync_TestWithNullNotificationDto_ValidUserId()
                {
                    //Arrange
                    var userId = Guid.NewGuid();
                    NotificationDTO notificationDto = null;

                    //Act & Assert
                    await Assert.ThrowsAsync<Exception>(() =>
                        _notificationWorker.SendNotificationAsync(userId, notificationDto));
                }
            }

            public class WhiteBoxTests
            {
                private readonly NotificationWorker _notificationWorker;
                private readonly Mock<ILogger<NotificationWorker>> _mockLogger;
                private readonly Mock<INotificationService> _mockNotificationService;
                private readonly Mock<IAmazonSimpleNotificationService> _mockSnsClient;

                public WhiteBoxTests()
                {
                    _mockLogger = new Mock<ILogger<NotificationWorker>>();
                    _mockNotificationService = new Mock<INotificationService>();
                    _mockSnsClient = new Mock<IAmazonSimpleNotificationService>();
                    _notificationWorker = new NotificationWorker(_mockLogger.Object,
                        _mockNotificationService.Object,
                        _mockSnsClient.Object);
                }

                [Fact]
                public async Task TestPath_1_2_3_5_6_7_8()
                {
                    // Arrange
                    var userId = GetValidUserId();
                    var notificationDto = CreateTestNotificationDto();
                    var endpointArns = new List<string>
                    {
                        "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone",
                        "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad"
                    };

                    _mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                        .ReturnsAsync(new Notification());
                    _mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                        .ReturnsAsync(endpointArns);
                    _mockSnsClient.Setup(s => s.PublishAsync(It.IsAny<PublishRequest>(), default))
                        .ReturnsAsync(new PublishResponse());

                    // Act
                    await _notificationWorker.SendNotificationAsync(userId, notificationDto);

                    // Assert
                    // Verifica che il logger sia stato chiamato un numero di volte compreso in un intervallo
                    // 1 ad inizio AddNotificationAsync, 1 alla fine, 1 quanod inizia ad inviare la notifica, 1 dopo la fine dell'invio di notifica.
                    // 2 per ogni endpoint.
                    int expectedInformationLogs = 4 + (endpointArns.Count * 2);

                    _mockLogger.Verify(
                        x => x.Log(
                            LogLevel.Information,
                            It.IsAny<EventId>(),
                            It.IsAny<It.IsAnyType>(),
                            It.IsAny<Exception>(),
                            (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                        Times.Between(5, expectedInformationLogs, Range.Inclusive));
                    _mockLogger.Verify(
                        x => x.Log(
                            LogLevel.Error,
                            It.IsAny<EventId>(),
                            It.IsAny<It.IsAnyType>(),
                            It.IsAny<Exception>(),
                            (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                        Times.Never);
                    _mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
                    _mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
                    _mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default),
                        Times.Exactly(endpointArns.Count));
                }

                [Fact]
                public async Task TestPath_1_2_10_8()
                {
                    //Arrange
                    Guid userId = Guid.Empty;
                    NotificationDTO notificationDto = null;
                    var exception = new Exception("One or more parameter is empty.");

                    // Act
                    await Assert.ThrowsAsync<Exception>(() =>
                        _notificationWorker.SendNotificationAsync(userId, notificationDto));

                    // Assert
                    _mockLogger.Verify(l => l.Log(
                            LogLevel.Error,
                            It.IsAny<EventId>(),
                            It.IsAny<It.IsAnyType>(),
                            It.IsAny<Exception>(),
                            (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                        Times.Once);
                    _mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Never);
                    _mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Never);
                    _mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default), Times.Never);
                }

                [Fact]
                public async Task TestPath_1_2_11_8()
                {
                    // Arrange
                    var userId = GetValidUserId();
                    var notificationDto = CreateTestNotificationDto();
                    var exception = new Exception("Add notification failed");

                    _mockNotificationService
                        .Setup(s => s.AddNotificationAsync(notificationDto, userId))
                        .ThrowsAsync(exception);

                    // Act
                    await _notificationWorker.SendNotificationAsync(userId, notificationDto);

                    // Assert
                    _mockLogger.Verify(l => l.Log(
                            LogLevel.Error,
                            It.IsAny<EventId>(),
                            It.IsAny<It.IsAnyType>(),
                            It.IsAny<Exception>(),
                            (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                        Times.AtLeastOnce);
                    _mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
                    _mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Never);
                    _mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default), Times.Never);
                }

                [Fact]
                public async Task TestPath_1_2_3_12_8()
                {

                    // Arrange
                    var userId = GetValidUserId();
                    var notificationDto = CreateTestNotificationDto();
                    var exception = new Exception("Get endpoints failed");

                    _mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                        .ReturnsAsync(new Notification());
                    _mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                        .ThrowsAsync(exception);

                    // Act
                    await _notificationWorker.SendNotificationAsync(userId, notificationDto);

                    // Assert
                    _mockLogger.Verify(l => l.Log(
                            LogLevel.Error,
                            It.IsAny<EventId>(),
                            It.IsAny<It.IsAnyType>(),
                            It.IsAny<Exception>(),
                            (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                        Times.AtLeastOnce);
                    _mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
                    _mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
                    _mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default), Times.Never);
                }

                [Fact]
                public async Task TestPath_1_2_3_4_8()
                {

                    // Arrange
                    var userId = GetValidUserId();
                    var notificationDto = CreateTestNotificationDto();

                    _mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                        .ReturnsAsync(new Notification());

                    _mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                        .ReturnsAsync(new List<string>());

                    // Act
                    await _notificationWorker.SendNotificationAsync(userId, notificationDto);

                    // Assert
                    _mockLogger.Verify(l => l.Log(
                            LogLevel.Warning,
                            It.IsAny<EventId>(),
                            It.Is<It.IsAnyType>((state, type) => state.ToString().Contains("No endpoints found")),
                            It.IsAny<Exception>(),
                            (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                        Times.Once);
                    _mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
                    _mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
                    _mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default), Times.Never);
                }

                [Fact]
                public async Task TestPathWithExceptionOnPublish_1_2_3_5_6_7_8()
                {
                    // Arrange
                    var userId = GetValidUserId();
                    var notificationDto = CreateTestNotificationDto();
                    var endpointArns = new List<string> { "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone" };
                    var exception = new Exception("Publish failed");

                    _mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                        .ReturnsAsync(new Notification());
                    _mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                        .ReturnsAsync(endpointArns);
                    _mockSnsClient.Setup(s => s.PublishAsync(It.IsAny<PublishRequest>(), default))
                        .ThrowsAsync(exception);

                    // Act
                    await _notificationWorker.SendNotificationAsync(userId, notificationDto);

                    // Assert
                    _mockLogger.Verify(
                        x => x.Log(
                            LogLevel.Error,
                            It.IsAny<EventId>(),
                            It.IsAny<It.IsAnyType>(),
                            exception,
                            It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                        Times.Once);
                    _mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
                    _mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
                    _mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default),
                        Times.Once);
                }

                [Fact]
                public async Task TestPathPublishFailsForOneEndpoint_1_2_3_5_6_7_8()
                {
                    // Arrange
                    var userId = GetValidUserId();
                    var notificationDto = CreateTestNotificationDto();
                    var endpointArns = new List<string>
                    {
                        "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone",
                        "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad",
                        "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone2"
                    };
                    var exception =
                        new Exception("Publish failed for arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad");

                    _mockNotificationService
                        .Setup(s => s.AddNotificationAsync(notificationDto, userId))
                        .ReturnsAsync(new Notification());
                    _mockNotificationService
                        .Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                        .ReturnsAsync(endpointArns);
                    // Successo per tutti gli endpoint eccetto arn:endpoint2
                    _mockSnsClient
                        .Setup(s => s.PublishAsync(
                            It.Is<PublishRequest>(p =>
                                p.TargetArn != "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad"), default))
                        .ReturnsAsync(new PublishResponse());
                    // Setup per "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad"
                    _mockSnsClient
                        .Setup(x => x.PublishAsync(
                            It.Is<PublishRequest>(p =>
                                p.TargetArn == "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad"), default))
                        .ThrowsAsync(exception);

                    // Act
                    await _notificationWorker.SendNotificationAsync(userId, notificationDto);

                    // Assert
                    _mockLogger.Verify(
                        x => x.Log(
                            LogLevel.Error,
                            It.IsAny<EventId>(),
                            It.IsAny<It.IsAnyType>(),
                            It.Is<Exception>(ex =>
                                ex.Message.Contains(
                                    "Publish failed for arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad")),
                            It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                        Times.Once);
                    _mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
                    _mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
                    _mockSnsClient.Verify(x => x.PublishAsync(It.Is<PublishRequest>(p =>
                            p.TargetArn == "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone"
                            || p.TargetArn == "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/iphone2"), default),
                        Times.Exactly(2));
                    _mockSnsClient.Verify(
                        x => x.PublishAsync(
                            It.Is<PublishRequest>(p =>
                                p.TargetArn == "arn:aws:sns:eu-west-1:123150819972:endpoint/APNS/ipad"), default),
                        Times.Once);
                }
            }
        }
    }
}