using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DietiDeals24.DataAccessLayer.Migrations
{
    /// <inheritdoc />
    public partial class removedCurrentPriceCheck : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_CurrentPrice",
                table: "Auction");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddCheckConstraint(
                name: "CK_CurrentPrice",
                table: "Auction",
                sql: "\"CurrentPrice\" >= \"StartingPrice\"");
        }
    }
}
