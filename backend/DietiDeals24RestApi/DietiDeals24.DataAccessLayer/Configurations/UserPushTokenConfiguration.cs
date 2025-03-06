using DietiDeals24.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DietiDeals24.DataAccessLayer.Configurations;

public class UserPushTokenConfiguration : IEntityTypeConfiguration<UserPushToken>
{
    public void Configure(EntityTypeBuilder<UserPushToken> builder)
    {
        builder.ToTable("UserPushToken");

        builder.HasKey(t => t.Id);

        builder.Property(t => t.Id)
            .IsRequired()
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(t => t.DeviceToken)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(t => t.RegistrationDate)
            .IsRequired()
            .HasColumnType("timestamp(0) without time zone");

        // Relationships
        builder.HasOne(t => t.User)
            .WithMany(u => u.UserPushTokens)
            .HasForeignKey(t => t.UserId);
    }
}
