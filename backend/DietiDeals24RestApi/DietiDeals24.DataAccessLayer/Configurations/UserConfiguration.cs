using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DietiDeals24.DataAccessLayer.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("User");

        builder.HasKey(u => u.Id);

        builder.Property(u => u.Id)
            .IsRequired();
            
        builder.Property(u => u.Username)
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(u => u.Fullname)
            .HasMaxLength(255);

        builder.Property(u => u.Email)
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(u => u.Role)
            .IsRequired();

        builder.Property(u => u.BirthDate)
            .IsRequired()
            .HasColumnType("timestamp without time zone");

        builder.Property(u => u.HasVerifiedEmail)
            .IsRequired()
            .HasDefaultValue(false);

        // Relationships
        builder.HasOne(u => u.Vendor)
            .WithOne(v => v.User)
            .HasForeignKey<Vendor>(v => v.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.Bids)
            .WithOne(b => b.Buyer)
            .HasForeignKey(b => b.BuyerId);

        builder.HasMany(u => u.Notifications)
            .WithOne(n => n.User)
            .HasForeignKey(n => n.UserId);

        builder.HasMany(u => u.UserPushTokens)
            .WithOne(t => t.User)
            .HasForeignKey(t => t.UserId);
    }
}