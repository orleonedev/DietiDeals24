using DietiDeals24.DataAccessLayer.Entities;
using DietiDeals24.DataAccessLayer.Models;
using DietiDeals24.DataAccessLayer.Services;

namespace DietiDeals24.RestApi.Workers;

public class AuctionWorker: IAuctionWorker
{
    private readonly ILogger<AuctionWorker> _logger;
    private readonly IAuctionService _auctionService;
    private readonly IVendorService _vendorService;
    private readonly IBidService _bidService;
    private readonly IImageService _imageService;
    private readonly EventBridgeSchedulerService _eventBridgeSchedulerService;

    public AuctionWorker(
        ILogger<AuctionWorker> logger, 
        IAuctionService auctionService,
        IVendorService vendorService,
        IBidService bidService,
        IImageService imageService, 
        EventBridgeSchedulerService eventBridgeSchedulerService)
    {
        _logger = logger;
        _auctionService = auctionService;
        _vendorService = vendorService;
        _bidService = bidService;
        _imageService = imageService;
        _eventBridgeSchedulerService = eventBridgeSchedulerService;
    }

    public async Task<Auction> GetAuctionById(Guid id)
    {
        _logger.LogInformation("[WORKER] Getting auction with id: {id}", id);
        var auction = await _auctionService.GetAuctionByIdAsync(id);
        return auction;
    }
    
    public async Task<List<Auction>> GetAllAuctions()
    {
        _logger.LogInformation("[WORKER] Getting all auctions");

        try
        {
            var auctions = await _auctionService.GetAllAuctionsAsync();

            return auctions.ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Getting all auctions failed: {ex.Message}");
            throw new Exception("[WORKER] Getting all auctions failed.", ex);
        }
    }

    public async Task<PaginatedResult<HomePageAuctionDTO>> GetPaginatedAuctions(AuctionFiltersDTO filters)
    {
        _logger.LogInformation("[WORKER] Getting paginated auctions.");

        try
        {
            // Fetch the ordered auctions directly from the service
            var auctions = await _auctionService.GetPaginatedAuctionsAsync(filters);
            var paginatedAuctions = new PaginatedResult<HomePageAuctionDTO>
            {
                Results = new List<HomePageAuctionDTO>(),
                TotalRecords = auctions.Count,
                PageNumber = filters.PageNumber,
                PageSize = filters.PageSize
            };

            // Fetch all bids & images
            var auctionIds = auctions.Select(auction => auction.Id).ToList();
            var bidsCountDict = await _bidService.GetBidsCountForAuctionAsync(auctionIds);
            var imagesDict = await _imageService.GetImagesUrlsForAuctionAsync(auctionIds);
            
            foreach (var auction in auctions)
            {
                paginatedAuctions.Results.Add(new HomePageAuctionDTO
                {
                    Id = auction.Id,
                    MainImageUrl = imagesDict.TryGetValue(auction.Id, out var images) && images.Any() ? images.First() : "",
                    Title = auction.Title,
                    Type = auction.AuctionType,
                    CurrentPrice = auction.CurrentPrice,
                    EndingDate = auction.EndingDate,
                    Bids = bidsCountDict.TryGetValue(auction.Id, out var bids) ? bids : 0
                });
            }

            return paginatedAuctions;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Getting paginated auctions failed: {ex.Message}");
            throw new Exception("[WORKER] Getting paginated auctions failed.", ex);
        }
    }

    
    public async Task<DetailedAuctionDTO> GetDetailedAuctionById(Guid id)
    {
        _logger.LogInformation("[WORKER] Getting the auction.");

        try
        {
            var auction = await _auctionService.GetAuctionByIdAsync(id);
            var vendor = await _vendorService.GetVendorByIdAsync(auction.VendorId);
            var bids = await _bidService.GetBidsCountForAuctionAsync(id);
            var images = await _imageService.GetImagesUrlsForAuctionAsync(id);
            
            return new DetailedAuctionDTO
            {
                Id = auction.Id,
                MainImageUrl = images.FirstOrDefault(),
                ImagesUrls = images,
                Title = auction.Title,
                Category = auction.Category,
                Type = auction.AuctionType,
                CurrentPrice = auction.CurrentPrice,
                StartingDate = auction.StartingDate,
                EndingDate = auction.EndingDate,
                Threshold = auction.Threshold,
                ThresholdTimer = auction.Timer,
                Bids = bids,
                Description = auction.AuctionDescription,
                Vendor = new DetailedVendorDTO
                {
                    Id = vendor.Id,
                    Name = vendor.User.Fullname,
                    Username = vendor.User.Username,
                    Email = vendor.User.Email,
                    SuccessfulAuctions = vendor.SuccessfulAuctions,
                    JoinedSince = vendor.StartingDate,
                    GeoLocation = vendor.GeoLocation,
                    WebSiteUrl = vendor.WebSiteUrl,
                    ShortBio = vendor.ShortBio
                },
                SecretPrice = auction.SecretPrice
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Getting detailed auction. Exception occurred: {ex.Message}");
            throw new Exception("[WORKER] Getting detailed auction failed.", ex);
        }
    }

    public async Task<CreateAuctionResponseDTO> CreateAuction(CreateAuctionDTO auctionDto)
    {
        _logger.LogInformation("[WORKER] Creating new auction");

        try
        {
            var vendor = await _vendorService.GetVendorByIdAsync(auctionDto.VendorId);
            var auction = await _auctionService.CreateAuctionAsync(auctionDto, vendor);
            var imagesDict = await _imageService.AddImagesUrlsForAuctionAsync(auction.Id, auctionDto.ImagesIdentifiers);
            var imagesUrls = await _imageService.GetImagesUrlsForAuctionAsync(auction.Id);

            var response = await _eventBridgeSchedulerService.ScheduleAuctionEndEvent(auction.Id.ToString(), auction.EndingDate);
            
            var detailedAuction = new DetailedAuctionDTO
            {
                Id = auction.Id,
                Title = auction.Title,
                Description = auction.AuctionDescription,
                Type = auction.AuctionType,
                Category = auctionDto.Category,
                StartingDate = auction.StartingDate,
                EndingDate = auction.EndingDate,
                CurrentPrice = auction.CurrentPrice,
                Threshold = auction.Threshold,
                ThresholdTimer = auction.Timer,
                Vendor = new DetailedVendorDTO
                {
                    Id = vendor.Id,
                    Name = vendor.User.Fullname,
                    Username = vendor.User.Username,
                    Email = vendor.User.Email,
                    SuccessfulAuctions = vendor.SuccessfulAuctions,
                    JoinedSince = vendor.StartingDate,
                    GeoLocation = vendor.GeoLocation,
                    WebSiteUrl = vendor.WebSiteUrl,
                    ShortBio = vendor.ShortBio
                },
                SecretPrice = auction.SecretPrice,
                MainImageUrl = imagesUrls.FirstOrDefault(),
                ImagesUrls = imagesUrls,
                Bids = 0
            };

            return new CreateAuctionResponseDTO
            {
                DetailedAuction = detailedAuction,
                ImagesPreSignedUrls = imagesDict
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] Creating new auction failed: {ex.Message}");
            throw new Exception("[WORKER] Creating new auction failed.", ex);
        }
    }

    public async Task OnAuctionEndTimeReached(Guid auctionId)
    {
        try
        {
            var auction = await _auctionService.GetAuctionByIdAsync(auctionId);

            if (auction.AuctionType == AuctionType.Incremental)
            {
                await OnIncrementalAuctionEndTimeReached(auction);
            }
            else
            {
                await OnDescendingAuctionEndTimeReached(auction);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"[WORKER] On Auction {auctionId} end time reached failed: {ex.Message}");
            throw new Exception($"[WORKER] On Auction {auctionId} end time reached failed.", ex);
        }
    }

    private async Task OnIncrementalAuctionEndTimeReached(Auction auction)
    {
        var bidsCount = await _bidService.GetBidsCountForAuctionAsync(auction.Id);
        var isSuccessfullyClosed = bidsCount > 0 ? true : false;
        auction.AuctionState = isSuccessfullyClosed ? AuctionState.Closed : AuctionState.Expired;
        await _auctionService.UpdateAuctionAsync(auction);
        
        //invia notifiche alle persone in base a isSuccessfullyClosed
        //caso 1 - chi ha vinto l'asta, quelli che hanno perso l'asta e il venditore
        //caso 2 - solo venditore
    }

    private async Task OnDescendingAuctionEndTimeReached(Auction auction)
    {
        auction.CurrentPrice -= auction.Threshold;

        if (auction.SecretPrice < auction.CurrentPrice)
        {
            DateTime now = DateTime.Now;
            DateTime actualDate = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
            auction.EndingDate = actualDate.AddHours(auction.Timer);
            
            var response = await _eventBridgeSchedulerService.ScheduleAuctionEndEvent(auction.Id.ToString(), auction.EndingDate);
            _logger.LogInformation("[WORKER] Decreased auction end time reached, event bridge triggered.");
            
            return;
        }
                
        auction.AuctionState = AuctionState.Expired;
        //notificare solo venditore
        
        await _auctionService.UpdateAuctionAsync(auction);
    }

}