using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DietiDeals24.DataAccessLayer.Configurations;

public class AuctionImageConfiguration : IEntityTypeConfiguration<AuctionImage>
{
    public void Configure(EntityTypeBuilder<AuctionImage> builder)
    {
        builder.ToTable("AuctionImage");

        builder.HasKey(ai => ai.Id);

        builder.Property(ai => ai.Id)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(ai => ai.Url)
            .IsRequired()
            .HasMaxLength(500);

        // Relationships
        builder.HasOne(ai => ai.Auction)
            .WithMany(a => a.AuctionImages)
            .HasForeignKey(ai => ai.AuctionId);
    }
}
