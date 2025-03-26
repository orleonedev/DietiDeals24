using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services.Impl;
using Microsoft.Extensions.Logging;
using Moq;

namespace DietiDeals24.RestApi.Test;

public class AuctionServiceTests // Black Box Test
{
    private readonly AuctionService _auctionService;
    private readonly Mock<IRepository<Auction, Guid>> _mockAuctionRepository;
    private readonly Mock<IUnitOfWork> _mockUnitOfWork;

    public AuctionServiceTests()
    {
        var mockLogger = new Mock<ILogger<AuctionService>>();
        _mockUnitOfWork = new Mock<IUnitOfWork>();
        _mockAuctionRepository = new Mock<IRepository<Auction, Guid>>();

        _mockUnitOfWork.Setup(unit => unit.AuctionRepository).Returns(_mockAuctionRepository.Object);
        _auctionService = new AuctionService(_mockUnitOfWork.Object, mockLogger.Object);
    }

    private static DateTime GetValidDate()
    {
        DateTime now = DateTime.Now;
        DateTime validDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
        return validDate;
    }

    private static Vendor GetValidInputForVendor()
    {
        var vendor = new Vendor
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            GeoLocation = "Napoli",
            WebSiteUrl = "www.unsemplicevenditore.com",
            ShortBio = "Un semplice venditore di Napoli.",
            StartingDate = GetValidDate(),
            SuccessfulAuctions = 2
        };

        return vendor;
    }

    private static CreateAuctionDTO GetValidInputForCreateAuctionDTO()
    {
        var createAuctionDto = new CreateAuctionDTO
        {
            Title = "iPhone 12 Usato - Buone condizioni",
            Description = "Vendo il mio iPhone 12. Nella scatola è incluso il caricatore.",
            Type = AuctionType.Incremental,
            Category = AuctionCategory.Services,
            StartingPrice = 200,
            Threshold = 25,
            ThresholdTimer = 3,
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
    public async Task CreateAuctionAsync_TestWithValidInut()
    {
        // Arrange
        var vendor = GetValidInputForVendor();
        var auctionDTO = GetValidInputForCreateAuctionDTO();
        auctionDTO.VendorId = vendor.Id;

        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()));
        _mockUnitOfWork.Setup(unit => unit.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(auctionDTO.Title, result.Title);
        Assert.Equal(auctionDTO.VendorId, result.VendorId);
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithMinValueDTO_ValidVendor()
    {
        // Arrange
        var vendor = GetValidInputForVendor();
        var auctionDTO = new CreateAuctionDTO
        {
            Title = "",
            Description = "",
            Type = AuctionType.Incremental,
            Category = AuctionCategory.Services,
            StartingPrice = 0,
            Threshold = 0,
            ThresholdTimer = 0,
            ImagesIdentifiers = new List<Guid>(),
            SecretPrice = null,
            VendorId = vendor.Id
        };

        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()));
        _mockUnitOfWork.Setup(unit => unit.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(auctionDTO.Title, result.Title);
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithMaxValueDTO_ValidVendor()
    {
        // Arrange
        var vendor = GetValidInputForVendor();
        var auctionDTO = new CreateAuctionDTO
        {
            Title = new string('A', 500),
            Description = new string('B', 1000),
            Type = AuctionType.Incremental,
            Category = AuctionCategory.Services,
            StartingPrice = decimal.MaxValue,
            Threshold = int.MaxValue,
            ThresholdTimer = 8760, //1 anno
            ImagesIdentifiers = new List<Guid>(Enumerable.Range(0, 100).Select(_ => Guid.NewGuid())),
            SecretPrice = decimal.MaxValue,
            VendorId = vendor.Id
        };

        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()));
        _mockUnitOfWork.Setup(unit => unit.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(auctionDTO.Title, result.Title);
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithValidDTO_MinValueVendor()
    {
        // Arrange
        var vendor = new Vendor
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            GeoLocation = "",
            WebSiteUrl = "",
            ShortBio = "",
            StartingDate = DateTime.MinValue,
            SuccessfulAuctions = 0
        };

        var auctionDTO = GetValidInputForCreateAuctionDTO();
        auctionDTO.VendorId = vendor.Id;

        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()));
        _mockUnitOfWork.Setup(unit => unit.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(auctionDTO.Title, result.Title);
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithValidDTO_MaxValueVendor()
    {
        // Arrange
        var vendor = new Vendor
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            GeoLocation = new string('X', 500),
            WebSiteUrl = "https://" + new string('Y', 490) + ".com",
            ShortBio = new string('Z', 1000),
            StartingDate = DateTime.MaxValue,
            SuccessfulAuctions = int.MaxValue
        };

        var auctionDTO = GetValidInputForCreateAuctionDTO();
        auctionDTO.VendorId = vendor.Id;

        _mockAuctionRepository.Setup(repo => repo.Add(It.IsAny<Auction>()));
        _mockUnitOfWork.Setup(unit => unit.Save()).ReturnsAsync(1);

        // Act
        var result = await _auctionService.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(auctionDTO.Title, result.Title);
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithNullDTO()
    {
        // Arrange
        var vendor = GetValidInputForVendor();

        // Act & Assert
        await Assert.ThrowsAsync<Exception>(() => _auctionService.CreateAuctionAsync(null, vendor));
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithNullVendor()
    {
        // Arrange
        var auctionDTO = GetValidInputForCreateAuctionDTO();

        // Act & Assert
        await Assert.ThrowsAsync<Exception>(() => _auctionService.CreateAuctionAsync(auctionDTO, null));
    }
}
