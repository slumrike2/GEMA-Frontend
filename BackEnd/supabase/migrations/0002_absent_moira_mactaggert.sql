ALTER TABLE "Equipment" ALTER COLUMN "state" SET DATA TYPE text;--> statement-breakpoint
ALTER TABLE "Equipment" ALTER COLUMN "state" SET DEFAULT 'en_inventario'::text;--> statement-breakpoint
DROP TYPE "public"."equipment_state";--> statement-breakpoint
CREATE TYPE "public"."equipment_state" AS ENUM('instalado', 'en_mantenimiento', 'mantenimiento_pendiente', 'en_reparaciones', 'reparaciones_pendientes', 'en_inventario', 'descomisionado', 'transferencia_pendiente');--> statement-breakpoint
ALTER TABLE "Equipment" ALTER COLUMN "state" SET DEFAULT 'en_inventario'::"public"."equipment_state";--> statement-breakpoint
ALTER TABLE "Equipment" ALTER COLUMN "state" SET DATA TYPE "public"."equipment_state" USING "state"::"public"."equipment_state";--> statement-breakpoint
ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE text;--> statement-breakpoint
DROP TYPE "public"."technician_speciality";--> statement-breakpoint
CREATE TYPE "public"."technician_speciality" AS ENUM('Electricista', 'Mecanica', 'Logistica', 'Electronica');--> statement-breakpoint
ALTER TABLE "Technical_team" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";--> statement-breakpoint
ALTER TABLE "Technician" ALTER COLUMN "speciality" SET DATA TYPE "public"."technician_speciality" USING "speciality"::"public"."technician_speciality";