ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
DROP TYPE "public"."technician_speciality";--> statement-breakpoint
CREATE TYPE "public"."technician_speciality" AS ENUM('Electricidad', 'Refrigeracion', 'Iluminacion', 'Pintura', 'Protocolo', 'IT');--> statement-breakpoint
ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";