using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DietiDeals24.DataAccessLayer.Configurations;

public class BidConfiguration : IEntityTypeConfiguration<Bid>
{
    public void Configure(EntityTypeBuilder<Bid> builder)
    {
        builder.ToTable("Bid", tableBuilder =>
        {
            tableBuilder.HasCheckConstraint("CK_Price", "\"Price\" >= 0");
        });

        builder.HasKey(b => b.Id);

        builder.Property(b => b.Id)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(b => b.Price)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(b => b.BidDate)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasColumnType("timestamp(0) without time zone")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        // Relationships
        builder.HasOne(b => b.Auction)
            .WithMany(a => a.Bids)
            .HasForeignKey(b => b.AuctionId);

        builder.HasOne(b => b.Buyer)
            .WithMany(u => u.Bids)
            .HasForeignKey(b => b.BuyerId);
    }
}
