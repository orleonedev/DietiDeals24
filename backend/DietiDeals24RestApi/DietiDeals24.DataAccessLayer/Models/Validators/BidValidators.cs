using FluentValidation;

namespace DietiDeals24.DataAccessLayer.Models.Validators;

public class CreateBidValidator: AbstractValidator<CreateBidDTO>
{
    public CreateBidValidator()
    {
        //Rule for validate create bid input 
        
        RuleFor(bid => bid.AuctionId)
            .NotEmpty().WithMessage("AuctionId is required.");
        
        RuleFor(bid => bid.BuyerId)
            .NotEmpty().WithMessage("BuyerId is required.");
        
        RuleFor(bid => bid.Price)
            .GreaterThan(0).WithMessage("Price must be a positive value.");
        
        RuleFor(bid => bid.BidDate)
            .NotEmpty().WithMessage("BidDate is required.");
    }
}