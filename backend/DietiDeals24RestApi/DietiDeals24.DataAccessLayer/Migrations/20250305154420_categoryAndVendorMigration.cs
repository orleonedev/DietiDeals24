using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DietiDeals24.DataAccessLayer.Migrations
{
    /// <inheritdoc />
    public partial class categoryAndVendorMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Auction_Category_CategoryId",
                table: "Auction");

            migrationBuilder.DropTable(
                name: "Category");

            migrationBuilder.DropIndex(
                name: "IX_Auction_CategoryId",
                table: "Auction");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "Auction");

            migrationBuilder.RenameColumn(
                name: "OfferDate",
                table: "Bid",
                newName: "BidDate");

            migrationBuilder.AddColumn<string>(
                name: "GeoLocation",
                table: "Vendor",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ShortBio",
                table: "Vendor",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "WebSiteUrl",
                table: "Vendor",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Category",
                table: "Auction",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GeoLocation",
                table: "Vendor");

            migrationBuilder.DropColumn(
                name: "ShortBio",
                table: "Vendor");

            migrationBuilder.DropColumn(
                name: "WebSiteUrl",
                table: "Vendor");

            migrationBuilder.DropColumn(
                name: "Category",
                table: "Auction");

            migrationBuilder.RenameColumn(
                name: "BidDate",
                table: "Bid",
                newName: "OfferDate");

            migrationBuilder.AddColumn<Guid>(
                name: "CategoryId",
                table: "Auction",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateTable(
                name: "Category",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Category", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Auction_CategoryId",
                table: "Auction",
                column: "CategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_Auction_Category_CategoryId",
                table: "Auction",
                column: "CategoryId",
                principalTable: "Category",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
