using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DietiDeals24.DataAccessLayer.Configurations;

public class AuctionConfiguration : IEntityTypeConfiguration<Auction>
{
    public void Configure(EntityTypeBuilder<Auction> builder)
    {
        builder.ToTable("Auction",
            tableBuilder =>
            {
                tableBuilder.HasCheckConstraint("CK_StartingPrice", "\"StartingPrice\" >= 0");
                tableBuilder.HasCheckConstraint("CK_CurrentPrice", "\"CurrentPrice\" >= \"StartingPrice\"");
                tableBuilder.HasCheckConstraint("CK_Threshold", "\"Threshold\" >= 1");
                tableBuilder.HasCheckConstraint("CK_Timer", "\"Timer\" >= 1");
                tableBuilder.HasCheckConstraint("CK_SecretPrice", "\"SecretPrice\" < \"StartingPrice\"");
            }
        );

        builder.HasKey(a => a.Id);

        builder.Property(a => a.Id)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(a => a.Title)
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(a => a.AuctionDescription)
            .HasColumnType("text");

        builder.Property(a => a.StartingPrice)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(a => a.CurrentPrice)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(a => a.AuctionType)
            .IsRequired();

        builder.Property(a => a.Threshold)
            .IsRequired()
            .HasDefaultValue(1);

        builder.Property(a => a.Timer)
            .IsRequired()
            .HasDefaultValue(1);

        builder.Property(a => a.SecretPrice)
            .HasColumnType("decimal(10,2)");

        builder.Property(a => a.StartingDate)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasColumnType("timestamp without time zone")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(a => a.EndingDate)
            .IsRequired()
            .HasColumnType("timestamp without time zone");

        // Relationships
        builder.HasOne(a => a.Vendor)
            .WithMany(v => v.Auctions)
            .HasForeignKey(a => a.VendorId);

        builder.HasOne(a => a.Category)
            .WithMany(c => c.Auctions)
            .HasForeignKey(a => a.CategoryId);

        builder.HasMany(a => a.AuctionImages)
            .WithOne(ai => ai.Auction)
            .HasForeignKey(ai => ai.AuctionId);

        builder.HasMany(a => a.Bids)
            .WithOne(b => b.Auction)
            .HasForeignKey(b => b.AuctionId);

        // builder.HasMany(a => a.Transactions)
        //     .WithOne(t => t.Auction)
        //     .HasForeignKey(t => t.AuctionId);
    }
}
