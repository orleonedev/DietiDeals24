using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DietiDeals24.DataAccessLayer.Configurations;

public class VendorConfiguration : IEntityTypeConfiguration<Vendor>
{
    public void Configure(EntityTypeBuilder<Vendor> builder)
    {
        builder.ToTable("Vendor", t => 
            t.HasCheckConstraint("CK_SuccessfulAuctions", "\"SuccessfulAuctions\" >= 0")
        );
        builder.HasKey(v => v.Id);

        builder.Property(v => v.Id)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(v => v.UserId)
            .IsRequired();

        builder.Property(v => v.StartingDate)
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .HasColumnType("timestamp(0) without time zone")
            .ValueGeneratedOnAdd();

        builder.Property(v => v.SuccessfulAuctions)
            .HasDefaultValue(0);

        builder.Property(v => v.GeoLocation)
            .HasColumnType("text");
        
        builder.Property(v => v.WebSiteUrl)
            .HasColumnType("text");
        
        builder.Property(v => v.ShortBio)
            .HasColumnType("text");

        // Relationships
        builder.HasOne(v => v.User)
            .WithOne(u => u.Vendor)
            .HasForeignKey<Vendor>(v => v.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(v => v.Auctions)
            .WithOne(a => a.Vendor)
            .HasForeignKey(a => a.VendorId);

        // builder.HasMany(v => v.Transactions)
        //     .WithOne(t => t.Vendor)
        //     .HasForeignKey(t => t.VendorId);
    }
}