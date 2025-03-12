using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DietiDeals24.DataAccessLayer.Migrations
{
    /// <inheritdoc />
    public partial class NotificationsAndUserPushTokenMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<DateTime>(
                name: "RegistrationDate",
                table: "UserPushToken",
                type: "timestamp(0) without time zone",
                nullable: false,
                defaultValueSql: "CURRENT_TIMESTAMP",
                oldClrType: typeof(DateTime),
                oldType: "timestamp(0) without time zone");

            migrationBuilder.AddColumn<string>(
                name: "EndPointArn",
                table: "UserPushToken",
                type: "character varying(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "AuctionTitle",
                table: "Notification",
                type: "character varying(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreationDate",
                table: "Notification",
                type: "timestamp(0) without time zone",
                nullable: false,
                defaultValueSql: "CURRENT_TIMESTAMP");

            migrationBuilder.AddColumn<string>(
                name: "MainImageUrl",
                table: "Notification",
                type: "character varying(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EndPointArn",
                table: "UserPushToken");

            migrationBuilder.DropColumn(
                name: "AuctionTitle",
                table: "Notification");

            migrationBuilder.DropColumn(
                name: "CreationDate",
                table: "Notification");

            migrationBuilder.DropColumn(
                name: "MainImageUrl",
                table: "Notification");

            migrationBuilder.AlterColumn<DateTime>(
                name: "RegistrationDate",
                table: "UserPushToken",
                type: "timestamp(0) without time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp(0) without time zone",
                oldDefaultValueSql: "CURRENT_TIMESTAMP");
        }
    }
}
