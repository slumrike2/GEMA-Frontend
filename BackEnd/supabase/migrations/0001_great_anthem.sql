ALTER TABLE "Equipment_operational_location" RENAME COLUMN "equipmentId" TO "equipmentUuid";--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" RENAME COLUMN "locationId" TO "locationTechnicalCode";--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT "Equipment_operational_location_equipmentId_Equipment_uuid_fk";
--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT "Equipment_operational_location_locationId_Technical_location_technicalCode_fk";
--> statement-breakpoint
ALTER TABLE "Technical_team" ADD COLUMN "leaderId" uuid;--> statement-breakpoint
ALTER TABLE "Technician" ADD COLUMN "technicalTeamId" serial NOT NULL;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD CONSTRAINT "Equipment_operational_location_equipmentUuid_Equipment_uuid_fk" FOREIGN KEY ("equipmentUuid") REFERENCES "public"."Equipment"("uuid") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD CONSTRAINT "Equipment_operational_location_locationTechnicalCode_Technical_location_technicalCode_fk" FOREIGN KEY ("locationTechnicalCode") REFERENCES "public"."Technical_location"("technicalCode") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technical_team" ADD CONSTRAINT "Technical_team_leaderId_Technician_uuid_fk" FOREIGN KEY ("leaderId") REFERENCES "public"."Technician"("uuid") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technician" ADD CONSTRAINT "Technician_technicalTeamId_Technical_team_id_fk" FOREIGN KEY ("technicalTeamId") REFERENCES "public"."Technical_team"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP COLUMN "id";