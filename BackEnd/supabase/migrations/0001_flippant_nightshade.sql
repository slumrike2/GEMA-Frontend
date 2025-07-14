CREATE TYPE "public"."technician_speciality" AS ENUM('electrician', 'mechanic', 'it', 'biomedical', 'other');--> statement-breakpoint
ALTER TABLE "Technician_specialties" DISABLE ROW LEVEL SECURITY;--> statement-breakpoint
DROP TABLE "Technician_specialties" CASCADE;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT IF EXISTS "Equipment_operational_location_equipmentId_Equipment_uuid_fk";--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT IF EXISTS "Equipment_operational_location_locationId_Technical_location_technicalCode_fk";--> statement-breakpoint
ALTER TABLE "Technical_team" DROP CONSTRAINT IF EXISTS "Technical_team_speciality_Technician_specialties_codeName_fk";--> statement-breakpoint
ALTER TABLE "Technician" DROP CONSTRAINT IF EXISTS "Technician_speciality_Technician_specialties_codeName_fk";--> statement-breakpoint
ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD COLUMN "equipmentUuid" uuid NOT NULL;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD COLUMN "locationTechnicalCode" text NOT NULL;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT IF EXISTS "Equipment_operational_location_pkey";--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD PRIMARY KEY ("equipmentUuid", "locationTechnicalCode");--> statement-breakpoint
ALTER TABLE "Technical_team" ADD COLUMN "leaderId" uuid;--> statement-breakpoint
ALTER TABLE "Technician" ADD COLUMN "technicalTeamId" serial NOT NULL;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD CONSTRAINT "Equipment_operational_location_equipmentUuid_Equipment_uuid_fk" FOREIGN KEY ("equipmentUuid") REFERENCES "public"."Equipment"("uuid") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD CONSTRAINT "Equipment_operational_location_locationTechnicalCode_Technical_location_technicalCode_fk" FOREIGN KEY ("locationTechnicalCode") REFERENCES "public"."Technical_location"("technicalCode") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technical_team" ADD CONSTRAINT "Technical_team_leaderId_Technician_uuid_fk" FOREIGN KEY ("leaderId") REFERENCES "public"."Technician"("uuid") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technician" ADD CONSTRAINT "Technician_technicalTeamId_Technical_team_id_fk" FOREIGN KEY ("technicalTeamId") REFERENCES "public"."Technical_team"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP COLUMN "id";--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP COLUMN "equipmentId";--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP COLUMN "locationId";