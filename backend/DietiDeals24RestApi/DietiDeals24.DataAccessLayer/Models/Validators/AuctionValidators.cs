using System.Collections.Generic;
using DietiDeals24.DataAccessLayer.Entities;
using FluentValidation;

namespace DietiDeals24.DataAccessLayer.Models.Validators;

public class CreateAuctionDTOValidator : AbstractValidator<CreateAuctionDTO>
{
    public CreateAuctionDTOValidator()
    {
        // Title and Description validation
        RuleFor(auction => auction.Title)
            .NotEmpty().WithMessage("Title is required.");
        
        RuleFor(auction => auction.Description)
            .NotEmpty().WithMessage("Description is required.");

        // Starting Price validation
        RuleFor(auction => auction.StartingPrice)
            .GreaterThan(0).WithMessage("Starting price must be a positive value.");

        // Threshold validation
        RuleFor(auction => auction.Threshold)
            .GreaterThan(0).WithMessage("Threshold must be a positive value.");

        // Threshold Timer validation
        RuleFor(auction => auction.ThresholdTimer)
            .GreaterThan(0).WithMessage("ThresholdTimer must be a positive number.");

        // Secret Price validation based on AuctionType
        RuleFor(auction => auction.SecretPrice)
            .Must((auction, secretPrice) => AuctionTypeAllowsSecretPrice(auction.Type, secretPrice))
            .WithMessage("Invalid Secret Price for the selected auction type.");

        // VendorId validation
        RuleFor(auction => auction.VendorId)
            .NotEmpty().WithMessage("VendorId is required.");
    }

    // Conditional logic for SecretPrice validation based on AuctionType
    private bool AuctionTypeAllowsSecretPrice(AuctionType type, decimal? secretPrice)
    {
        // If the auction type is Incremental, SecretPrice must be null
        if (type == AuctionType.Incremental)
            return secretPrice == null; // SecretPrice must be null for Incremental auctions

        // For other auction types, SecretPrice must either be null or a positive value
        return secretPrice == null || secretPrice > 0;
    }
}
