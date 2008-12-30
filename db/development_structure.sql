CREATE TABLE "holidays" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "holiday" date, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "intervals" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "start" datetime, "end" datetime, "user_id" integer, "task_id" integer, "hours" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "projections" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "task_id" integer, "start" date, "end" date, "confidence" decimal, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "taggings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "tag_id" integer, "taggable_id" integer, "tagger_id" integer, "tagger_type" varchar(255), "taggable_type" varchar(255), "context" varchar(255), "created_at" datetime);
CREATE TABLE "tags" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255));
CREATE TABLE "tasks" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "type" varchar(255), "description" text, "low" decimal, "high" decimal, "completed" boolean, "user_id" integer, "start" date, "parent_id" integer, "lft" integer, "rgt" integer, "created_at" datetime, "updated_at" datetime, "cached_tag_list" varchar(255), "due" date);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "login" varchar(255), "efficiency" decimal, "created_at" datetime, "updated_at" datetime);
CREATE INDEX "index_taggings_on_tag_id" ON "taggings" ("tag_id");
CREATE INDEX "index_taggings_on_taggable_id_and_taggable_type_and_context" ON "taggings" ("taggable_id", "taggable_type", "context");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20081221223117');

INSERT INTO schema_migrations (version) VALUES ('20081222020258');

INSERT INTO schema_migrations (version) VALUES ('20081222085823');

INSERT INTO schema_migrations (version) VALUES ('20081223034305');

INSERT INTO schema_migrations (version) VALUES ('20081228065708');

INSERT INTO schema_migrations (version) VALUES ('20081228080145');

INSERT INTO schema_migrations (version) VALUES ('20081229075521');

INSERT INTO schema_migrations (version) VALUES ('20081229181711');