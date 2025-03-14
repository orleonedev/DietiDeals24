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

ALTER TABLE "Auction" ADD "Category" integer NOT NULL DEFAULT 0;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250305154420_categoryAndVendorMigration', '9.0.0');

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250305160510_categoryAndVendorMigrationFix', '9.0.0');

ALTER TABLE "User" DROP COLUMN "CognitoSub";

ALTER TABLE "Vendor" ALTER COLUMN "StartingDate" TYPE timestamp(0) without time zone;

ALTER TABLE "UserPushToken" ALTER COLUMN "RegistrationDate" TYPE timestamp(0) without time zone;

ALTER TABLE "User" ALTER COLUMN "Id" DROP DEFAULT;

ALTER TABLE "Bid" ALTER COLUMN "BidDate" TYPE timestamp(0) without time zone;

ALTER TABLE "Auction" ALTER COLUMN "StartingDate" TYPE timestamp(0) without time zone;

ALTER TABLE "Auction" ALTER COLUMN "EndingDate" TYPE timestamp(0) without time zone;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250306183524_userAndAuctionFix', '9.0.0');

ALTER TABLE "UserPushToken" ALTER COLUMN "RegistrationDate" SET DEFAULT (CURRENT_TIMESTAMP);

ALTER TABLE "UserPushToken" ADD "EndPointArn" character varying(500) NOT NULL DEFAULT '';

ALTER TABLE "Notification" ADD "AuctionTitle" character varying(255) NOT NULL DEFAULT '';

ALTER TABLE "Notification" ADD "CreationDate" timestamp(0) without time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP);

ALTER TABLE "Notification" ADD "MainImageUrl" character varying(500) NOT NULL DEFAULT '';

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250312223128_NotificationsAndUserPushTokenMigration', '9.0.0');

ALTER TABLE "Notification" ALTER COLUMN "MainImageUrl" DROP NOT NULL;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250314123013_FixNonNullabelImageInNotifications', '9.0.0');

COMMIT;



START TRANSACTION;

-- Insert sample data for User
insert into "User" ("Id", "Username", "Fullname", "Email", "Role", "BirthDate", "HasVerifiedEmail")
values  ('029514c4-8061-701f-e59d-5db76100eb60', 'oleonetest01', 'Oleone Test01', 'orleone.dev+Test01@gmail.com', 1, '1996-12-20 00:00:00.000000', true),
        ('e2055474-2031-7029-bc20-ecc047057846', 'test-buyer', 'Test Buyer', 'orleone.dev+TestBuyer@gmail.com', 0, '2005-01-11 00:00:00.000000', true),
        ('a2654474-d0e1-703f-4c1a-e2a5467de321', 'test-buyer2', 'Test Buyer2', 'orleone.dev+TestBuyer2@gmail.com', 0, '1998-11-11 00:00:00.000000', true),
        ('02f50404-a051-70b5-7812-1bb1861b1ecb', 'test-buyer4', 'Test Buyer4', 'orleone.dev+TestBuyer4@gmail.com', 0, '1996-05-03 00:00:00.000000', true),
        ('a2d53494-5041-70ca-c1af-c405ce4c259d', 'test-buyer6', 'Test Buyer6', 'orleone.dev+TestBuyer6@gmail.com', 0, '1996-05-03 00:00:00.000000', true),
        ('02955454-3071-7059-93da-063efa24f563', 'testbuyer7', 'Test Buyer 7', 'orleone.dev+TestBuyer7@gmail.com', 0, '2025-03-12 00:00:00.000000', true),
        ('f2e5f4f4-b041-70ed-5905-32ef889f8bb8', 'testbuyer8', 'Test Buyer 8', 'orleone.dev+TestBuyer8@gmail.com', 0, '2025-03-12 00:00:00.000000', true),
        ('92a5c4b4-6031-70d3-9e54-c6ddac2af2b3', 'test-buyer5', 'Test Buyer5', 'orleone.dev+TestBuyer5@gmail.com', 0, '1996-05-03 00:00:00.000000', true),
        ('72159444-d071-7025-645c-45e0fd6fed46', 'testseller1', 'Test Seller 1', 'orleone.dev+TestSeller1@gmail.com', 1, '2025-03-12 00:00:00.000000', true),
        ('52a514f4-70e1-70b5-49d8-edffabdedb5d', 'sideshowgibbon', 'Giuseppe Falso', 'sideshowgibbon@gmail.com', 1, '1997-08-15 00:00:00.000000', true);

-- Insert sample data for Vendor
insert into "Vendor" ("Id", "UserId", "StartingDate", "SuccessfulAuctions", "GeoLocation", "ShortBio", "WebSiteUrl")
values  ('40799cb4-d12c-4225-bae2-d2cb06ab51e0', '029514c4-8061-701f-e59d-5db76100eb60', '2025-03-06 20:45:36', 0, 'Napoli', 'una breve descrizione', 'https://orleonedev.github.io/'),
        ('78afb6a7-2e31-42a7-a758-7732e592dba4', '72159444-d071-7025-645c-45e0fd6fed46', '2025-03-12 01:08:14', 0, 'Napoli', 'Solo un semplice venditore nel chill', 'Https://un-venditore-nel-chill.io'),
        ('7baccfa3-e8a1-43b1-b6c4-f6f47a13c708', '52a514f4-70e1-70b5-49d8-edffabdedb5d', '2025-03-12 23:13:59', 0, 'Napoli', 'Un venditore in gamba', 'https://github.com/giuseppe-not-true');

-- Insert sample data for Auction
insert into "Auction" ("Id", "Title", "AuctionDescription", "StartingPrice", "CurrentPrice", "AuctionType", "Threshold", "Timer", "SecretPrice", "VendorId", "AuctionState", "StartingDate", "EndingDate", "Category")
values  ('4bfa9ae5-7667-414e-a25f-ba12148f56d9', 'carta pokemon interessante', 'vendo le carte aperte da quesye bustine, giusto per ripagarmele', 15.00, 15.00, 1, 2, 1, null, '7baccfa3-e8a1-43b1-b6c4-f6f47a13c708', 2, '2025-03-13 10:12:29', '2025-03-13 11:12:29', 3),
        ('ac6fb771-c43c-4974-a279-506e5cd3ac82', 'asta test', 'jdkdjd', 123.00, 123.00, 1, 12, 1, null, '7baccfa3-e8a1-43b1-b6c4-f6f47a13c708', 2, '2025-03-13 19:14:31', '2025-03-13 20:14:31', 1);

-- Insert sample data for AuctionImage
insert into "AuctionImage" ("Id", "AuctionId", "Url")
values  ('184af91c-0d3a-4fa2-ac17-d5a9042e43ad', '4bfa9ae5-7667-414e-a25f-ba12148f56d9', 'https://sigma63-dietideals24-auction-images.s3.amazonaws.com/auction-4bfa9ae5-7667-414e-a25f-ba12148f56d9/184af91c-0d3a-4fa2-ac17-d5a9042e43ad.jpeg'),
        ('b59cc0fd-4b2c-4248-89a3-bcca81f1ce71', '4bfa9ae5-7667-414e-a25f-ba12148f56d9', 'https://sigma63-dietideals24-auction-images.s3.amazonaws.com/auction-4bfa9ae5-7667-414e-a25f-ba12148f56d9/b59cc0fd-4b2c-4248-89a3-bcca81f1ce71.jpeg');

COMMIT;