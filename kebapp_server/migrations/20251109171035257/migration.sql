BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "group" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "timeOfDay" bigint NOT NULL,
    "location" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "group_title_unique" ON "group" USING btree ("title");

--
-- ACTION ALTER TABLE
--
DROP INDEX "title_unique";
CREATE UNIQUE INDEX "meal_title_unique" ON "meal" USING btree ("title");
--
-- ACTION CREATE TABLE
--
CREATE TABLE "member" (
    "id" bigserial PRIMARY KEY,
    "groupId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "accepted" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "groupId_userId_unique" ON "member" USING btree ("groupId", "userId");

--
-- ACTION DROP TABLE
--
DROP TABLE "order" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "order" (
    "id" bigserial PRIMARY KEY,
    "memberId" bigint NOT NULL,
    "mealId" bigint NOT NULL,
    "remarks" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "member_order_unique" ON "order" USING btree ("memberId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "member"
    ADD CONSTRAINT "member_fk_0"
    FOREIGN KEY("groupId")
    REFERENCES "group"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "order"
    ADD CONSTRAINT "order_fk_0"
    FOREIGN KEY("memberId")
    REFERENCES "member"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "order"
    ADD CONSTRAINT "order_fk_1"
    FOREIGN KEY("mealId")
    REFERENCES "meal"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR kebapp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('kebapp', '20251109171035257', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251109171035257', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20240520102713718', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240520102713718', "timestamp" = now();


COMMIT;
