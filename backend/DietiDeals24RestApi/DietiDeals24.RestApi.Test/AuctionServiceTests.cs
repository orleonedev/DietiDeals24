using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services.Impl;
using Microsoft.Extensions.Logging;
using Moq;

namespace DietiDeals24.RestApi.Test;

public class AuctionServiceTests // Black Box test
{
    private readonly Mock<ILogger<AuctionService>> _mockLogger;
    private readonly Mock<IUnitOfWork> _mockUnitOfWork;
    private readonly Mock<IRepository<Auction, Guid>> _mockAuctionRepository;
    private readonly AuctionService _auctionService;

    public AuctionServiceTests()
    {
        _mockLogger = new Mock<ILogger<AuctionService>>();
        _mockUnitOfWork = new Mock<IUnitOfWork>();
        _mockAuctionRepository = new Mock<IRepository<Auction, Guid>>();
        _mockUnitOfWork.Setup(uow => uow.AuctionRepository).Returns(_mockAuctionRepository.Object); 
        _auctionService = new AuctionService(_mockUnitOfWork.Object, _mockLogger.Object);
    }

    private static DateTime GetValidDate()
    {
        DateTime now = DateTime.Now;
        DateTime validDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
        return validDate;
    }

    private static Vendor GetValidVendor()
    {
        var vendor = new Vendor
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            GeoLocation = "Napoli",
            WebSiteUrl = "www.website.com",
            ShortBio = "A short bio.",
            StartingDate = GetValidDate(),
            SuccessfulAuctions = 2
        };

        return vendor;
    }

    private static CreateAuctionDTO GetValidCreateAuctionDTO()
    {
        var createAuctionDto = new CreateAuctionDTO
        {
            Title = "Auction Title",
            Description = "Auction Description",
            Type = AuctionType.Incremental,
            Category = AuctionCategory.Services,
            StartingPrice = 5,
            Threshold = 5,
            ThresholdTimer = 1,
            ImagesIdentifiers = new List<Guid>
            {
                Guid.NewGuid(),
                Guid.NewGuid(),
                Guid.NewGuid()
            },
            SecretPrice = null,
            VendorId = Guid.NewGuid(),
        };
        
        return createAuctionDto;
    }

    [Fact]
    public async Task CreateAuctionAsync_ValidInput_ReturnsAuction()
    {
        // Arrange
        var vendor = GetValidVendor();
        var createAuctionDto = GetValidCreateAuctionDTO();
        Auction capturedAuction = null; //variabile per catturare l'asta

        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()))
            .Callback<Auction>(auction => capturedAuction = auction); // Usa Callback
        _mockUnitOfWork.Setup(uow => uow.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(createAuctionDto, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.NotNull(capturedAuction);
        _mockAuctionRepository.Verify(repo => repo.Add(It.IsAny<Auction>()), Times.Once);
        _mockUnitOfWork.Verify(uow => uow.Save(), Times.Once);
    }
    
    [Fact]
    public async Task CreateAuctionAsync_MinValuesDto_ValidVendor_ReturnsAuction()
    {
        // Arrange
        var vendor = GetValidVendor();
        var createAuctionDto = new CreateAuctionDTO
        {
            Title = "",               // valore minimo
            Description = "",         // valore minimo
            Type = AuctionType.Incremental,
            Category = AuctionCategory.Services,
            StartingPrice = 0,        // valore minimo
            Threshold = 0,            // valore minimo
            ThresholdTimer = 0,       // valore minimo
            ImagesIdentifiers = new List<Guid>(), // lista vuota
            SecretPrice = null,
            VendorId = vendor.Id
        };

        Auction capturedAuction = null;
        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()))
            .Callback<Auction>(auction => capturedAuction = auction);
        _mockUnitOfWork.Setup(uow => uow.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(createAuctionDto, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.NotNull(capturedAuction);
        _mockAuctionRepository.Verify(repo => repo.Add(It.IsAny<Auction>()), Times.Once);
        _mockUnitOfWork.Verify(uow => uow.Save(), Times.Once);
    }
    
    [Fact]
    public async Task CreateAuctionAsync_MaxValuesDto_ValidVendor_ReturnsAuction()
    {
        // Arrange
        var vendor = GetValidVendor();
        var createAuctionDto = new CreateAuctionDTO
        {
            Title = new string('A', 500),           // stringa molto lunga
            Description = new string('B', 1000),      // stringa molto lunga
            Type = AuctionType.Incremental,
            Category = AuctionCategory.Services,
            StartingPrice = decimal.MaxValue,       // valore massimo
            Threshold = int.MaxValue,               // valore massimo
            ThresholdTimer = 8760,          // 1 anno
            ImagesIdentifiers = Enumerable.Range(0, 100)
                .Select(_ => Guid.NewGuid())
                .ToList(),  // lista molto grande
            SecretPrice = decimal.MaxValue,         // valore massimo
            VendorId = vendor.Id
        };

        Auction capturedAuction = null;
        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()))
            .Callback<Auction>(auction => capturedAuction = auction);
        _mockUnitOfWork.Setup(uow => uow.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(createAuctionDto, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.NotNull(capturedAuction);
        _mockAuctionRepository.Verify(repo => repo.Add(It.IsAny<Auction>()), Times.Once);
        _mockUnitOfWork.Verify(uow => uow.Save(), Times.Once);
    }
    
    [Fact]
    public async Task CreateAuctionAsync_ValidDto_MinValuesVendor_ReturnsAuction()
    {
        // Arrange
        var vendor = new Vendor
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            GeoLocation = "",             // stringa vuota
            WebSiteUrl = "",              // stringa vuota
            ShortBio = "",                // stringa vuota
            StartingDate = DateTime.MinValue, // data minima
            SuccessfulAuctions = 0        // valore minimo
        };

        var createAuctionDto = GetValidCreateAuctionDTO();
        createAuctionDto.VendorId = vendor.Id; // assicurati di sincronizzare l'id

        Auction capturedAuction = null;
        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()))
            .Callback<Auction>(auction => capturedAuction = auction);
        _mockUnitOfWork.Setup(uow => uow.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(createAuctionDto, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.NotNull(capturedAuction);
        _mockAuctionRepository.Verify(repo => repo.Add(It.IsAny<Auction>()), Times.Once);
        _mockUnitOfWork.Verify(uow => uow.Save(), Times.Once);
    }
    
    [Fact]
    public async Task CreateAuctionAsync_ValidDto_MaxValuesVendor_ReturnsAuction()
    {
        // Arrange
        var vendor = new Vendor
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            GeoLocation = new string('X', 500),   // stringa molto lunga
            WebSiteUrl = "https://" + new string('Y', 490) + ".com", // URL molto lungo
            ShortBio = new string('Z', 1000),    // bio lunghissima
            StartingDate = DateTime.MaxValue,    // data massima
            SuccessfulAuctions = int.MaxValue    // numero massimo di aste
        };

        var createAuctionDto = GetValidCreateAuctionDTO();
        createAuctionDto.VendorId = vendor.Id; // Assicuriamoci che il VendorId sia coerente

        Auction capturedAuction = null;
        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()))
            .Callback<Auction>(auction => capturedAuction = auction);
        _mockUnitOfWork.Setup(uow => uow.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(createAuctionDto, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.NotNull(capturedAuction);
        _mockAuctionRepository.Verify(repo => repo.Add(It.IsAny<Auction>()), Times.Once);
        _mockUnitOfWork.Verify(uow => uow.Save(), Times.Once);
    }

    [Fact]
    public async Task CreateAuctionAsync_NullCreateAuctionDto_ThrowsArgumentNullException()
    {
        // Arrange
        var vendor = GetValidVendor();
        CreateAuctionDTO createAuctionDto = null;
        
        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()))
            .ThrowsAsync(new Exception("CreateAuctionDTO null exception"));
        
        //Act
        var exception = await Assert.ThrowsAsync<Exception>(() => _auctionService.CreateAuctionAsync(createAuctionDto, vendor));

        //Assert
        Assert.IsType<Exception>(exception);
        _mockAuctionRepository.Verify(repo => repo.Add(It.IsAny<Auction>()), Times.Never);
    }

    [Fact]
    public async Task CreateAuctionAsync_NullVendor_ThrowsArgumentNullException()
    {
        // Arrange
        Vendor vendor = null;
        var createAuctionDto = GetValidCreateAuctionDTO();
        
        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()))
            .ThrowsAsync(new Exception("CreateAuctionDTO null exception"));
        
        //Act
        var exception = await Assert.ThrowsAsync<Exception>(() => _auctionService.CreateAuctionAsync(createAuctionDto, vendor));

        //Assert
        Assert.IsType<Exception>(exception);
        _mockAuctionRepository.Verify(repo => repo.Add(It.IsAny<Auction>()), Times.Never);
    }
}