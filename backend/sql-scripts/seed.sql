CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;
CREATE TABLE "Category" (
    "Id" uuid NOT NULL,
    "Name" character varying(255) NOT NULL,
    "Description" text NOT NULL,
    CONSTRAINT "PK_Category" PRIMARY KEY ("Id")
);

CREATE TABLE "User" (
    "Id" uuid NOT NULL,
    "CognitoSub" character varying(255) NOT NULL,
    "Username" character varying(100) NOT NULL,
    "Fullname" character varying(255) NOT NULL,
    "Email" character varying(255) NOT NULL,
    "Role" integer NOT NULL,
    "BirthDate" timestamp without time zone NOT NULL,
    "HasVerifiedEmail" boolean NOT NULL DEFAULT FALSE,
    CONSTRAINT "PK_User" PRIMARY KEY ("Id")
);

CREATE TABLE "UserPushToken" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "DeviceToken" character varying(255) NOT NULL,
    "RegistrationDate" timestamp without time zone NOT NULL,
    CONSTRAINT "PK_UserPushToken" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_UserPushToken_User_UserId" FOREIGN KEY ("UserId") REFERENCES "User" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Vendor" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "StartingDate" timestamp without time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "SuccessfulAuctions" integer NOT NULL DEFAULT 0,
    CONSTRAINT "PK_Vendor" PRIMARY KEY ("Id"),
    CONSTRAINT "CK_SuccessfulAuctions" CHECK ("SuccessfulAuctions" >= 0),
    CONSTRAINT "FK_Vendor_User_UserId" FOREIGN KEY ("UserId") REFERENCES "User" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Auction" (
    "Id" uuid NOT NULL,
    "Title" character varying(255) NOT NULL,
    "AuctionDescription" text NOT NULL,
    "StartingPrice" numeric(10,2) NOT NULL,
    "CurrentPrice" numeric(10,2) NOT NULL,
    "AuctionType" integer NOT NULL,
    "Threshold" numeric NOT NULL DEFAULT 1.0,
    "Timer" integer NOT NULL DEFAULT 1,
    "SecretPrice" numeric(10,2),
    "VendorId" uuid NOT NULL,
    "CategoryId" uuid NOT NULL,
    "AuctionState" integer NOT NULL,
    "StartingDate" timestamp without time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "EndingDate" timestamp without time zone NOT NULL,
    CONSTRAINT "PK_Auction" PRIMARY KEY ("Id"),
    CONSTRAINT "CK_CurrentPrice" CHECK ("CurrentPrice" >= "StartingPrice"),
    CONSTRAINT "CK_SecretPrice" CHECK ("SecretPrice" < "StartingPrice"),
    CONSTRAINT "CK_StartingPrice" CHECK ("StartingPrice" >= 0),
    CONSTRAINT "CK_Threshold" CHECK ("Threshold" >= 1),
    CONSTRAINT "CK_Timer" CHECK ("Timer" >= 1),
    CONSTRAINT "FK_Auction_Category_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES "Category" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Auction_Vendor_VendorId" FOREIGN KEY ("VendorId") REFERENCES "Vendor" ("Id") ON DELETE CASCADE
);

CREATE TABLE "AuctionImage" (
    "Id" uuid NOT NULL,
    "AuctionId" uuid NOT NULL,
    "Url" character varying(500) NOT NULL,
    CONSTRAINT "PK_AuctionImage" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_AuctionImage_Auction_AuctionId" FOREIGN KEY ("AuctionId") REFERENCES "Auction" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Bid" (
    "Id" uuid NOT NULL,
    "AuctionId" uuid NOT NULL,
    "BuyerId" uuid NOT NULL,
    "Price" numeric(10,2) NOT NULL,
    "OfferDate" timestamp without time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Bid" PRIMARY KEY ("Id"),
    CONSTRAINT "CK_Price" CHECK ("Price" >= 0),
    CONSTRAINT "FK_Bid_Auction_AuctionId" FOREIGN KEY ("AuctionId") REFERENCES "Auction" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Bid_User_BuyerId" FOREIGN KEY ("BuyerId") REFERENCES "User" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Notification" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "AuctionId" uuid NOT NULL,
    "NotificationType" integer NOT NULL,
    "Message" text NOT NULL,
    CONSTRAINT "PK_Notification" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Notification_Auction_AuctionId" FOREIGN KEY ("AuctionId") REFERENCES "Auction" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Notification_User_UserId" FOREIGN KEY ("UserId") REFERENCES "User" ("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_Auction_CategoryId" ON "Auction" ("CategoryId");

CREATE INDEX "IX_Auction_VendorId" ON "Auction" ("VendorId");

CREATE INDEX "IX_AuctionImage_AuctionId" ON "AuctionImage" ("AuctionId");

CREATE INDEX "IX_Bid_AuctionId" ON "Bid" ("AuctionId");

CREATE INDEX "IX_Bid_BuyerId" ON "Bid" ("BuyerId");

CREATE INDEX "IX_Notification_AuctionId" ON "Notification" ("AuctionId");

CREATE INDEX "IX_Notification_UserId" ON "Notification" ("UserId");

CREATE INDEX "IX_UserPushToken_UserId" ON "UserPushToken" ("UserId");

CREATE UNIQUE INDEX "IX_Vendor_UserId" ON "Vendor" ("UserId");

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250112001730_InitialCreate', '9.0.0');

ALTER TABLE "Vendor" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

ALTER TABLE "UserPushToken" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

ALTER TABLE "User" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

ALTER TABLE "Notification" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

ALTER TABLE "Category" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

ALTER TABLE "Bid" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

ALTER TABLE "AuctionImage" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

ALTER TABLE "Auction" ALTER COLUMN "Id" SET DEFAULT (gen_random_uuid());

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250114201125_defaultUUIDGeneration', '9.0.0');

ALTER TABLE "Auction" DROP CONSTRAINT "CK_CurrentPrice";

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250117230812_removedCurrentPriceCheck', '9.0.0');

ALTER TABLE "Auction" DROP CONSTRAINT "FK_Auction_Category_CategoryId";

DROP TABLE "Category";

DROP INDEX "IX_Auction_CategoryId";

ALTER TABLE "Auction" DROP COLUMN "CategoryId";

ALTER TABLE "Bid" RENAME COLUMN "OfferDate" TO "BidDate";

ALTER TABLE "Vendor" ADD "GeoLocation" text;

ALTER TABLE "Vendor" ADD "ShortBio" text;

ALTER TABLE "Vendor" ADD "WebSiteUrl" text;

ALTER TABLE "Auction" ADD "Category" integer NOT NULL;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250305154420_categoryAndVendorMigration', '9.0.0');

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250305160510_categoryAndVendorMigrationFix', '9.0.0');

COMMIT;


START TRANSACTION;

-- Insert sample data for User
INSERT INTO "User" ("Id", "CognitoSub", "Username", "Fullname", "Email", "Role", "BirthDate", "HasVerifiedEmail") 
VALUES 
(gen_random_uuid(), 'sub-12344', 'buyerNot', 'Unk nown', 'unk.nown@example.com', 0, '1980-01-01', false),
(gen_random_uuid(), 'sub-12345', 'buyer1', 'John Doe', 'john.doe@example.com', 0, '1990-01-01', true),
(gen_random_uuid(), 'sub-12346', 'buyer2', 'Jane Smith', 'jane.smith@example.com', 0, '1985-05-15', true),
(gen_random_uuid(), 'sub-12347', 'seller1', 'Alice Johnson', 'alice.johnson@example.com', 1, '1992-03-20', true),
(gen_random_uuid(), 'sub-12348', 'seller2', 'Bob Williams', 'bob.williams@example.com', 1, '1987-11-10', true);

-- Insert sample data for Vendor
INSERT INTO "Vendor" ("Id", "UserId", "StartingDate", "SuccessfulAuctions", "GeoLocation", "WebSiteUrl", "ShortBio") 
VALUES 
(gen_random_uuid(), (SELECT "Id" FROM "User" WHERE "Username" = 'seller1'), '2025-01-01', 5, 'Napoli', 'www.google.com', 'Test bio1.'),
(gen_random_uuid(), (SELECT "Id" FROM "User" WHERE "Username" = 'seller2'), '2025-01-10', 3, 'Latina', 'www.google.com', 'Test bio2.');

-- Insert sample data for Auction
INSERT INTO "Auction" ("Id", "Title", "AuctionDescription", "StartingPrice", "CurrentPrice", "AuctionType", "Threshold", "Timer", "SecretPrice", "VendorId", "Category", "AuctionState", "StartingDate", "EndingDate") 
VALUES 
(gen_random_uuid(), 'Laptop Auction', 'Brand new laptop, starting price $350', 350.00, 430.00, 1, 25, 48, NULL, 
 (SELECT "Id" FROM "Vendor" WHERE "UserId" = (SELECT "Id" FROM "User" WHERE "Username" = 'seller1')), 
 2, 
 0, '2025-01-17 10:00:00', '2025-01-19 23:00:00'),
 (gen_random_uuid(), 'iPad Air', 'Brand new iPad.', 325.00, 450.00, 1, 25, 48, NULL, 
 (SELECT "Id" FROM "Vendor" WHERE "UserId" = (SELECT "Id" FROM "User" WHERE "Username" = 'seller1')), 
 2, 
 0, '2025-01-17 10:00:00', '2025-01-19 23:00:00'),
(gen_random_uuid(), 'Vintage Chair', 'Antique chair from the 1800s', 300.00, 250.00, 2, 25, 12, 80.00, 
 (SELECT "Id" FROM "Vendor" WHERE "UserId" = (SELECT "Id" FROM "User" WHERE "Username" = 'seller2')), 
 3, 
 1, '2025-01-18 00:00:00', '2025-01-19 12:00:00'),
 (gen_random_uuid(), 'Modern Table', 'An elegant modern table', 600.00, 600.00, 1, 50, 72, NULL, 
 (SELECT "Id" FROM "Vendor" WHERE "UserId" = (SELECT "Id" FROM "User" WHERE "Username" = 'seller2')), 
 3, 
 2, '2025-01-10 12:00:00', '2025-01-13 12:00:00'),
(gen_random_uuid(), 'T-Shirt Auction', 'Limited edition t-shirts', 10.00, 25.00, 1, 5, 24, NULL, 
 (SELECT "Id" FROM "Vendor" WHERE "UserId" = (SELECT "Id" FROM "User" WHERE "Username" = 'seller1')), 
 4, 
 0, '2025-01-17 09:00:00', '2025-01-19 06:00:00'),
 (gen_random_uuid(), 'Levis Blue Jeans', 'Used levi blue jeans.', 15.00, 30.00, 1, 5, 24, NULL, 
 (SELECT "Id" FROM "Vendor" WHERE "UserId" = (SELECT "Id" FROM "User" WHERE "Username" = 'seller1')), 
 4, 
 0, '2025-01-17 09:00:00', '2025-01-19 06:00:00');

-- Insert sample data for AuctionImage
INSERT INTO "AuctionImage" ("Id", "AuctionId", "Url") 
VALUES 
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'Laptop Auction'), 'https://fastly.picsum.photos/id/237/200/200.jpg?hmac=zHUGikXUDyLCCmvyww1izLK3R3k8oRYBRiTizZEdyfI'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'Laptop Auction'), 'https://fastly.picsum.photos/id/237/200/200.jpg?hmac=zHUGikXUDyLCCmvyww1izLK3R3k8oRYBRiTizZEdyfI'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'Vintage Chair'), 'https://fastly.picsum.photos/id/237/200/200.jpg?hmac=zHUGikXUDyLCCmvyww1izLK3R3k8oRYBRiTizZEdyfI'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'Modern Table'), 'https://fastly.picsum.photos/id/237/200/200.jpg?hmac=zHUGikXUDyLCCmvyww1izLK3R3k8oRYBRiTizZEdyfI'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'T-Shirt Auction'), 'https://fastly.picsum.photos/id/237/200/200.jpg?hmac=zHUGikXUDyLCCmvyww1izLK3R3k8oRYBRiTizZEdyfI'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'T-Shirt Auction'), 'https://fastly.picsum.photos/id/237/200/200.jpg?hmac=zHUGikXUDyLCCmvyww1izLK3R3k8oRYBRiTizZEdyfI');

-- Insert sample data for Bid
INSERT INTO "Bid" ("Id", "AuctionId", "BuyerId", "Price", "BidDate") 
VALUES 
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'Laptop Auction'), 
 (SELECT "Id" FROM "User" WHERE "Username" = 'buyer1'), 375.00, '2025-01-17 14:00:00'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'Laptop Auction'), 
 (SELECT "Id" FROM "User" WHERE "Username" = 'buyer2'), 430.00, '2025-01-17 23:00:00'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'Vintage Chair'), 
 (SELECT "Id" FROM "User" WHERE "Username" = 'buyer2'), 250.00, '2025-01-19 08:00:00'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'T-Shirt Auction'), 
 (SELECT "Id" FROM "User" WHERE "Username" = 'buyer1'), 16.00, '2025-01-17 13:00:00'),
(gen_random_uuid(), (SELECT "Id" FROM "Auction" WHERE "Title" = 'T-Shirt Auction'), 
 (SELECT "Id" FROM "User" WHERE "Username" = 'buyer2'), 25.00, '2025-01-18 06:00:00');

COMMIT;