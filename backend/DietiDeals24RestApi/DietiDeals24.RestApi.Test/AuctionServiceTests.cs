using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Infrastructure;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;
using DietiDeals24.DataAccessLayer.Services.Impl;
using Microsoft.Extensions.Logging;
using Moq;

namespace DietiDeals24.RestApi.Test;

public class AuctionServiceTests // Black Box test
{
    private readonly Mock<IAuctionService> _mockAuctionService;

    public AuctionServiceTests()
    {
        _mockAuctionService = new Mock<IAuctionService>();
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
        Auction setupAuction = null; 

        _mockAuctionService.Setup(service => service.CreateAuctionAsync(auctionDTO, vendor))
            .ReturnsAsync(setupAuction);

        // Act
        var auction = await _mockAuctionService.Object.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        _mockAuctionService.Verify(service => service.CreateAuctionAsync(auctionDTO, vendor), Times.Once);
        Assert.Equal(auction, setupAuction);
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

        Auction setupAuction = null;
        
        _mockAuctionService.Setup(service => service.CreateAuctionAsync(auctionDTO, vendor))
            .ReturnsAsync(setupAuction);

        // Act
        var auction = await _mockAuctionService.Object.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        _mockAuctionService.Verify(service => service.CreateAuctionAsync(auctionDTO, vendor), Times.Once);
        Assert.Equal(auction, setupAuction);
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
            ThresholdTimer = 8760,          // 1 anno
            ImagesIdentifiers = Enumerable.Range(0, 100)
                .Select(_ => Guid.NewGuid())
                .ToList(),  
            SecretPrice = decimal.MaxValue,         
            VendorId = vendor.Id
        };

        Auction setupAuction = null;
        
        _mockAuctionService.Setup(service => service.CreateAuctionAsync(auctionDTO, vendor))
            .ReturnsAsync(setupAuction);

        // Act
        var auction = await _mockAuctionService.Object.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        _mockAuctionService.Verify(service => service.CreateAuctionAsync(auctionDTO, vendor), Times.Once);
        Assert.Equal(auction, setupAuction);
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

        Auction setupAuction = null;
        
        _mockAuctionService.Setup(service => service.CreateAuctionAsync(auctionDTO, vendor))
            .ReturnsAsync(setupAuction);

        // Act
        var auction = await _mockAuctionService.Object.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        _mockAuctionService.Verify(service => service.CreateAuctionAsync(auctionDTO, vendor), Times.Once);
        Assert.Equal(auction, setupAuction);
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

        Auction setupAuction = null;
        
        _mockAuctionService.Setup(service => service.CreateAuctionAsync(auctionDTO, vendor))
            .ReturnsAsync(setupAuction);

        // Act
        var auction = await _mockAuctionService.Object.CreateAuctionAsync(auctionDTO, vendor);

        // Assert
        _mockAuctionService.Verify(service => service.CreateAuctionAsync(auctionDTO, vendor), Times.Once);
        Assert.Equal(auction, setupAuction);
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithNullDTO()
    {
        // Arrange
        var vendor = GetValidInputForVendor();
        CreateAuctionDTO auctionDTO = null;
        
        _mockAuctionService.Setup(service => service.CreateAuctionAsync(auctionDTO, vendor))
            .ThrowsAsync(new ArgumentNullException("CreateAuctionDTO parameter is null."));

        // Act
        var exception = await Assert.ThrowsAsync<ArgumentNullException>(() => _mockAuctionService.Object.CreateAuctionAsync(auctionDTO, vendor));

        //Assert
        Assert.IsType<ArgumentNullException>(exception);
        _mockAuctionService.Verify(service => service.CreateAuctionAsync(auctionDTO, vendor), Times.Once);
    }

    [Fact]
    public async Task CreateAuctionAsync_TestWithNullVendor()
    {
        // Arrange
        Vendor vendor = null;
        var auctionDTO = GetValidInputForCreateAuctionDTO();
        
        _mockAuctionService.Setup(service => service.CreateAuctionAsync(auctionDTO, vendor))
            .ThrowsAsync(new ArgumentNullException("Vendor parameter is null."));

        // Act
        var exception = await Assert.ThrowsAsync<ArgumentNullException>(() => _mockAuctionService.Object.CreateAuctionAsync(auctionDTO, vendor));

        //Assert
        Assert.IsType<ArgumentNullException>(exception);
        _mockAuctionService.Verify(service => service.CreateAuctionAsync(auctionDTO, vendor), Times.Once);
    }
}