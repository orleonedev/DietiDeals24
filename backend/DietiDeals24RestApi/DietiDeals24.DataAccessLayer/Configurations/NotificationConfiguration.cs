using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DietiDeals24.DataAccessLayer.Configurations;

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.ToTable("Notification");

        builder.HasKey(n => n.Id);

        builder.Property(n => n.Id)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(n => n.UserId)
            .IsRequired();
        
        builder.Property(n => n.AuctionId)
            .IsRequired();
        
        builder.Property(n => n.NotificationType)
            .IsRequired();
        
        builder.Property(n => n.Message)
            .IsRequired()
            .HasColumnType("text");

        // Relationships
        builder.HasOne(n => n.User)
            .WithMany(u => u.Notifications)
            .HasForeignKey(n => n.UserId);

        builder.HasOne(n => n.Auction)
            .WithMany()
            .HasForeignKey(n => n.AuctionId);
    }
}
