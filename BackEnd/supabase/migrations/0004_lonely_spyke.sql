CREATE TABLE "Report_Equipment" (
	"reportId" serial NOT NULL,
	"equipmentUuid" uuid NOT NULL,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp,
	CONSTRAINT "Report_Equipment_reportId_equipmentUuid_pk" PRIMARY KEY("reportId","equipmentUuid")
);
--> statement-breakpoint
CREATE TABLE "Report_Technical_Location" (
	"reportId" serial NOT NULL,
	"technicalCode" text NOT NULL,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp,
	CONSTRAINT "Report_Technical_Location_reportId_technicalCode_pk" PRIMARY KEY("reportId","technicalCode")
);
--> statement-breakpoint
ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
DROP TYPE "public"."technician_speciality";--> statement-breakpoint
CREATE TYPE "public"."technician_speciality" AS ENUM('Electricidad', 'Refrigeracion', 'Iluminacion', 'Pintura', 'Protocolo', 'IT');--> statement-breakpoint
ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";--> statement-breakpoint
ALTER TABLE "Report_Equipment" ADD CONSTRAINT "Report_Equipment_reportId_Report_id_fk" FOREIGN KEY ("reportId") REFERENCES "public"."Report"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Report_Equipment" ADD CONSTRAINT "Report_Equipment_equipmentUuid_Equipment_uuid_fk" FOREIGN KEY ("equipmentUuid") REFERENCES "public"."Equipment"("uuid") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Report_Technical_Location" ADD CONSTRAINT "Report_Technical_Location_reportId_Report_id_fk" FOREIGN KEY ("reportId") REFERENCES "public"."Report"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Report_Technical_Location" ADD CONSTRAINT "Report_Technical_Location_technicalCode_Technical_location_technicalCode_fk" FOREIGN KEY ("technicalCode") REFERENCES "public"."Technical_location"("technicalCode") ON DELETE cascade ON UPDATE cascade;