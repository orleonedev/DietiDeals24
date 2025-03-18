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

public class NotificationWorkerTests // White box test
{
    private static Mock<ILogger<NotificationWorker>> CreateMockLogger()
    {
        return new Mock<ILogger<NotificationWorker>>();
    }

    private static Mock<INotificationService> CreateMockNotificationService()
    {
        return new Mock<INotificationService>();
    }

    private static Mock<IAmazonSimpleNotificationService> CreateMockSnsClient()
    {
        return new Mock<IAmazonSimpleNotificationService>();
    }
    
    private static NotificationDTO CreateTestNotificationDto()
    {
        return new NotificationDTO
        {
            Type = NotificationType.AuctionExpired,
            Message = "Test Message",
            AuctionId = Guid.NewGuid(),
            AuctionTitle = "Test Auction Title"
        };
    }
    
    [Collection("Sequential")]
    public class AddNotificationAsyncTests
    {
        private readonly Mock<INotificationWorker> _notificationWorkerMock;

        public AddNotificationAsyncTests()
        {
            _notificationWorkerMock = new Mock<INotificationWorker>();
        }

        [Fact]
        public async Task AddNotificationTokenAsync_ValidInput_ShouldCompleteSuccessfully()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var deviceToken = "valid_device_token";

            _notificationWorkerMock
                .Setup(worker => worker.AddNotificationTokenAsync(userId, deviceToken))
                .Returns(Task.CompletedTask);

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await worker.AddNotificationTokenAsync(userId, deviceToken);
        }

        [Fact]
        public async Task AddNotificationTokenAsync_InvalidUserId_ShouldThrowException()
        {
            // Arrange
            var invalidUserId = Guid.Empty;
            var deviceToken = "valid_device_token";

            _notificationWorkerMock
                .Setup(worker => worker.AddNotificationTokenAsync(invalidUserId, deviceToken))
                .ThrowsAsync(new ArgumentException("User ID cannot be empty"));

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => worker.AddNotificationTokenAsync(invalidUserId, deviceToken));
        }

        [Fact]
        public async Task AddNotificationTokenAsync_EmptyDeviceToken_ShouldThrowException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var emptyDeviceToken = "";

            _notificationWorkerMock
                .Setup(worker => worker.AddNotificationTokenAsync(userId, emptyDeviceToken))
                .ThrowsAsync(new ArgumentException("Device token cannot be empty"));

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => worker.AddNotificationTokenAsync(userId, emptyDeviceToken));
        }

        [Fact]
        public async Task AddNotificationTokenAsync_NullDeviceToken_ShouldThrowArgumentNullException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            string nullDeviceToken = null;

            _notificationWorkerMock
                .Setup(worker => worker.AddNotificationTokenAsync(userId, nullDeviceToken))
                .ThrowsAsync(new ArgumentNullException(nameof(nullDeviceToken)));

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentNullException>(() => worker.AddNotificationTokenAsync(userId, nullDeviceToken));
        }

        [Fact]
        public async Task AddNotificationTokenAsync_TooLongDeviceToken_ShouldThrowArgumentException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var longDeviceToken = new string('a', 300); // Simuliamo un token molto lungo

            _notificationWorkerMock
                .Setup(worker => worker.AddNotificationTokenAsync(userId, longDeviceToken))
                .ThrowsAsync(new ArgumentException("Device token is too long"));

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => worker.AddNotificationTokenAsync(userId, longDeviceToken));
        }

        [Fact]
        public async Task AddNotificationTokenAsync_InvalidCharactersInDeviceToken_ShouldThrowArgumentException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var invalidDeviceToken = "invalid_token_#*"; // Supponiamo che caratteri speciali non siano accettati

            _notificationWorkerMock
                .Setup(worker => worker.AddNotificationTokenAsync(userId, invalidDeviceToken))
                .ThrowsAsync(new ArgumentException("Device token contains invalid characters"));

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => worker.AddNotificationTokenAsync(userId, invalidDeviceToken));
        }

        [Fact]
        public async Task AddNotificationTokenAsync_UserNotFound_ShouldThrowKeyNotFoundException()
        {
            // Arrange
            var nonExistingUserId = Guid.NewGuid();
            var deviceToken = "valid_device_token";

            _notificationWorkerMock
                .Setup(worker => worker.AddNotificationTokenAsync(nonExistingUserId, deviceToken))
                .ThrowsAsync(new KeyNotFoundException("User not found"));

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await Assert.ThrowsAsync<KeyNotFoundException>(() => worker.AddNotificationTokenAsync(nonExistingUserId, deviceToken));
        }

        [Fact]
        public async Task RemoveNotificationTokenAsync_ValidInput_ShouldCompleteSuccessfully()
        {
            // Arrange
            var deviceToken = "valid_device_token";

            _notificationWorkerMock
                .Setup(worker => worker.RemoveNotificationTokenAsync(deviceToken))
                .Returns(Task.CompletedTask);

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await worker.RemoveNotificationTokenAsync(deviceToken);
        }

        [Fact]
        public async Task RemoveNotificationTokenAsync_NullOrEmptyToken_ShouldThrowException()
        {
            // Arrange
            string emptyToken = "";
            string nullToken = null;

            _notificationWorkerMock
                .Setup(worker => worker.RemoveNotificationTokenAsync(emptyToken))
                .ThrowsAsync(new ArgumentException("Device token cannot be empty"));

            _notificationWorkerMock
                .Setup(worker => worker.RemoveNotificationTokenAsync(nullToken))
                .ThrowsAsync(new ArgumentNullException(nameof(nullToken)));

            var worker = _notificationWorkerMock.Object;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => worker.RemoveNotificationTokenAsync(emptyToken));
            await Assert.ThrowsAsync<ArgumentNullException>(() => worker.RemoveNotificationTokenAsync(nullToken));
        }
    }
    
    [Collection("Sequential")]
    public class SendNotificationAsyncTests
    {

        [Fact]
        public async Task SendNotificationAsync_SuccessfulFlow_SendsNotifications()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();

            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            var endpointArns = new List<string> { "arn:endpoint1", "arn:endpoint2" };

            mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());
            mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ReturnsAsync(endpointArns);
            mockSnsClient.Setup(s => s.PublishAsync(It.IsAny<PublishRequest>(), default))
                .ReturnsAsync(new PublishResponse());

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            // Assert
            // Verifica che il logger sia stato chiamato un numero di volte compreso in un intervallo
            // Calcoliamo quanti log Information ci aspettiamo.
            // 1 per l'inizio, 1 per la fine dell'addNotification, 1 per l'inizio dell'invio, 1 per la fine dell'invio.
            // 2 per ogni endpoint per la creazione e l'invio.
            int expectedInformationLogs = 4 + (endpointArns.Count * 2);

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                Times.Between(expectedInformationLogs, expectedInformationLogs, Range.Inclusive));

            //Verifica che almeno un log di errore non sia stato generato.
            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()),
                Times.Never);

            mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default),
                Times.Exactly(endpointArns.Count));
        }

        [Fact]
        public async Task SendNotificationAsync_AddNotificationFails_LogsError()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();

            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            var exception = new Exception("Add notification failed");

            mockNotificationService
                .Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ThrowsAsync(exception);

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            //Calcolo dei log attesi
            int expectedErrorLogs = 1; // 1 log di errore per l'eccezione
            int expectedInformationLogs = 1; // 1 log informativo all'inizio della funzione.

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    exception,
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(expectedErrorLogs, expectedErrorLogs, Range.Inclusive));

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(expectedInformationLogs, expectedInformationLogs, Range.Inclusive));
            
            mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Never);
            mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default), Times.Never);
        }

        [Fact]
        public async Task SendNotificationAsync_GetEndpointsFails_LogsError()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();

            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            var exception = new Exception("Get endpoints failed");

            mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());

            mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ThrowsAsync(exception);

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            //Calcolo dei log attesi
            int expectedErrorLogs = 1; 
            int expectedInformationLogs = 3;

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    exception,
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(expectedErrorLogs, expectedErrorLogs, Range.Inclusive));

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(expectedInformationLogs, expectedInformationLogs, Range.Inclusive));
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default), Times.Never);
        }

        [Fact]
        public async Task SendNotificationAsync_NoEndpointsFound_LogsWarning()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();

            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();

            mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());

            mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ReturnsAsync(new List<string>());

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            //Calcolo dei log attesi
            int expectedWarningLogs = 1; 
            int expectedInformationLogs = 3;

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Warning,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(expectedWarningLogs, expectedWarningLogs, Range.Inclusive));
            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(expectedInformationLogs, expectedInformationLogs, Range.Inclusive));
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default), Times.Never);
        }

        [Fact]
        public async Task SendNotificationAsync_PublishFails_LogsError()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();
            
            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            var endpointArns = new List<string> { "arn:endpoint1" };
            var exception = new Exception("Publish failed");

            mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());
            mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ReturnsAsync(endpointArns);
            mockSnsClient.Setup(s => s.PublishAsync(It.IsAny<PublishRequest>(), default))
                .ThrowsAsync(exception);

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            //int expectedErrorLogs = 1; 
            int expectedInformationLogs = 4 + (endpointArns.Count * 2) ;

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    exception,
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Once);

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(5, expectedInformationLogs, Range.Inclusive));
            mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default),
                Times.Once);
        }
        
        [Fact]
        public async Task SendNotificationAsync_PublishAsyncOneEndpointFails_ContinuesProcessing()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();
            
            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);
            
            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            var endpointArns = new List<string> { "arn:endpoint1", "arn:endpoint2", "arn:endpoint3" };
            var exception = new Exception("Publish failed for arn:endpoint2");
            
            // Setup per AddNotificationAsync e GetEndPointArnFromUserIdAsync
            mockNotificationService
                .Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());
            mockNotificationService
                .Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ReturnsAsync(endpointArns);
            // Setup per PublishAsync:
            // Successo per tutti gli endpoint eccetto arn:endpoint2
            mockSnsClient
                .Setup(s => s.PublishAsync(It.Is<PublishRequest>(p => p.TargetArn != "arn:endpoint2"), default))
                .ReturnsAsync(new PublishResponse());
            // Setup per "arn:endpoint2": Simula errore
            mockSnsClient
                .Setup(x => x.PublishAsync(It.Is<PublishRequest>(p => p.TargetArn == "arn:endpoint2"), default))
                .ThrowsAsync(exception);
            
            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);
            
            // Assert
            int expectedInformationLogs = 4 + (endpointArns.Count * 2);  // Basato sul tuo criterio

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(5, expectedInformationLogs, Range.Inclusive));
            
            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.Is<Exception>(ex => ex.Message.Contains("Publish failed for arn:endpoint2")),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Once);
            mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(x => x.PublishAsync(It.Is<PublishRequest>(p => p.TargetArn == "arn:endpoint1"), default), Times.Once);
            mockSnsClient.Verify(x => x.PublishAsync(It.Is<PublishRequest>(p => p.TargetArn == "arn:endpoint2"), default), Times.Once);
            mockSnsClient.Verify(x => x.PublishAsync(It.Is<PublishRequest>(p => p.TargetArn == "arn:endpoint3"), default), Times.Once);
        }

        [Theory]
        [InlineData(NotificationType.AuctionExpired, "Auction expired")]
        [InlineData(NotificationType.AuctionBid, "New Bid")]
        [InlineData(NotificationType.AuctionClosed, "Auction Closed")]
        [InlineData((NotificationType)999, "Unknown Notification Type")] //simula default nello switch
        public async Task SendNotificationAsync_DifferentNotificationTypes_SetsCorrectTitle(NotificationType type,
            string expectedTitle)
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();
            
            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            notificationDto.Type = type;
            var endpointArns = new List<string> { "arn:endpoint1" };

            mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());
            mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ReturnsAsync(endpointArns);
            mockSnsClient
                .Setup(s => s.PublishAsync(It.Is<PublishRequest>(req => req.Message.Contains(expectedTitle)), default))
                .ReturnsAsync(new PublishResponse());

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            //Calcolo dei log attesi
            int expectedWarningLogs = 1; 
            int expectedInformationLogs = 4 + (endpointArns.Count * 2);
            
            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Warning,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(0, expectedWarningLogs, Range.Inclusive));

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(5, expectedInformationLogs, Range.Inclusive));
            
            mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(
                s => s.PublishAsync(It.Is<PublishRequest>(req => req.Message.Contains(expectedTitle)), default),
                Times.Once);
        }

        [Fact]
        public async Task SendNotificationAsync_ValidPayloadConstruction()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();
            
            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            var endpointArns = new List<string> { "arn:endpoint1" };

            mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());

            mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ReturnsAsync(endpointArns);
            mockSnsClient.Setup(s => s.PublishAsync(It.IsAny<PublishRequest>(), default))
                .ReturnsAsync(new PublishResponse());

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            int expectedInformationLogs = 4 + (endpointArns.Count * 2);

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(5, expectedInformationLogs, Range.Inclusive));
            mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(s => s.PublishAsync(It.Is<PublishRequest>(req =>
                req.MessageStructure == "json" &&
                req.Message.Contains(notificationDto.Message) &&
                req.Message.Contains(notificationDto.AuctionTitle) &&
                req.Message.Contains(notificationDto.AuctionId.ToString()) &&
                req.Message.Contains("APNS")
            ), default), Times.Once);
        }

        [Fact]
        public async Task SendNotificationAsync_MultipleEndpoints_SendsNotificationsToAll()
        {
            // Arrange
            var mockLogger = CreateMockLogger();
            var mockNotificationService = CreateMockNotificationService();
            var mockSnsClient = CreateMockSnsClient();
            
            var notificationWorker = new NotificationWorker(
                mockLogger.Object,
                mockNotificationService.Object,
                mockSnsClient.Object);

            var userId = Guid.NewGuid();
            var notificationDto = CreateTestNotificationDto();
            var endpointArns = new List<string> { "arn:endpoint1", "arn:endpoint2", "arn:endpoint3" };

            mockNotificationService.Setup(s => s.AddNotificationAsync(notificationDto, userId))
                .ReturnsAsync(new Notification());

            mockNotificationService.Setup(s => s.GetEndPointArnFromUserIdAsync(userId))
                .ReturnsAsync(endpointArns);
            mockSnsClient.Setup(s => s.PublishAsync(It.IsAny<PublishRequest>(), default))
                .ReturnsAsync(new PublishResponse());

            // Act
            await notificationWorker.SendNotificationAsync(userId, notificationDto);

            // Assert
            int expectedInformationLogs = 4 + (endpointArns.Count * 2);

            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception, string>>()),
                Times.Between(5, expectedInformationLogs, Range.Inclusive));
            mockNotificationService.Verify(s => s.AddNotificationAsync(notificationDto, userId), Times.Once);
            mockNotificationService.Verify(s => s.GetEndPointArnFromUserIdAsync(userId), Times.Once);
            mockSnsClient.Verify(s => s.PublishAsync(It.IsAny<PublishRequest>(), default),
                Times.Exactly(endpointArns.Count));
        }
    }
}