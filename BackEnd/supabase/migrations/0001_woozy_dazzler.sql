ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT "Equipment_operational_location_locationTechnicalCode_Technical_location_technicalCode_fk";
--> statement-breakpoint
ALTER TABLE "Technical_location" DROP CONSTRAINT "Technical_location_parentTechnicalCode_Technical_location_technicalCode_fk";
--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT "Equipment_operational_location_equipmentUuid_locationTechnicalCode_pk";--> statement-breakpoint
ALTER TABLE "Technical_location" ALTER COLUMN "parentTechnicalCode" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "Technical_team" ALTER COLUMN "leaderId" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "technicalTeamId" SET DATA TYPE integer;--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "technicalTeamId" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "User" ALTER COLUMN "createdAt" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "Report" ADD COLUMN "technicalTeamId" integer;--> statement-breakpoint
ALTER TABLE "Report_Update" ADD COLUMN "report_id" integer NOT NULL;