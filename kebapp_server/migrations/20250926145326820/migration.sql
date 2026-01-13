BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "meal" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "basePrice" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "title_unique" ON "meal" USING btree ("title");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "meal_input" (
    "id" bigserial PRIMARY KEY,
    "mealId" bigint NOT NULL,
    "description" text NOT NULL,
    "multipleChoice" boolean NOT NULL,
    "isExclusion" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "mealId_description_unique" ON "meal_input" USING btree ("mealId", "description");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "meal_input_option" (
    "id" bigserial PRIMARY KEY,
    "mealInputId" bigint NOT NULL,
    "description" text NOT NULL,
    "additionalPrice" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "mealInputId_description_unique" ON "meal_input_option" USING btree ("mealInputId", "description");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "order" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "mealId" bigint NOT NULL,
    "remarks" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "userId_unique" ON "order" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "order_option" (
    "id" bigserial PRIMARY KEY,
    "orderId" bigint NOT NULL,
    "mealInputOptionId" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "orderId_mealInputOptionId_unique" ON "order_option" USING btree ("orderId", "mealInputOptionId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "meal_input"
    ADD CONSTRAINT "meal_input_fk_0"
    FOREIGN KEY("mealId")
    REFERENCES "meal"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "meal_input_option"
    ADD CONSTRAINT "meal_input_option_fk_0"
    FOREIGN KEY("mealInputId")
    REFERENCES "meal_input"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "order"
    ADD CONSTRAINT "order_fk_0"
    FOREIGN KEY("mealId")
    REFERENCES "meal"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "order_option"
    ADD CONSTRAINT "order_option_fk_0"
    FOREIGN KEY("orderId")
    REFERENCES "order"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "order_option"
    ADD CONSTRAINT "order_option_fk_1"
    FOREIGN KEY("mealInputOptionId")
    REFERENCES "meal_input_option"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR kebapp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('kebapp', '20250926145326820', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250926145326820', "timestamp" = now();

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
