ALTER TABLE "Equipment_operational_location" DROP CONSTRAINT IF EXISTS "Equipment_operational_location_pkey";
ALTER TABLE"Equipment_operational_location" ADD PRIMARY KEY ("equipmentUuid", "locationTechnicalCode");

ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
DROP TYPE "public"."technician_speciality";--> statement-breakpoint
technician_speciality AS ENUM ('Electricidad', 'Refrigeracion', 'Iluminacion', 'Pintura', 'Protocolo', 'IT')
ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";