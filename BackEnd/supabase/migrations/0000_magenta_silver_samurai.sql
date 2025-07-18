CREATE TYPE "public"."equipment_state" AS ENUM('instalado', 'en_mantenimiento', 'mantenimiento_pendiente', 'en_reparaciones', 'reparaciones_pendientes', 'en_inventario', 'descomisionado', 'transferencia_pendiente');--> statement-breakpoint
CREATE TYPE "public"."Report_Origin_Source" AS ENUM('email', 'managementSystem', 'chat', 'GEMA');--> statement-breakpoint
CREATE TYPE "public"."report_priority" AS ENUM('high', 'medium', 'low');--> statement-breakpoint
CREATE TYPE "public"."report_state" AS ENUM('pending', 'programmed', 'in_progress', 'solved', 'cancelled');--> statement-breakpoint
CREATE TYPE "public"."report_type" AS ENUM('preventive', 'active');--> statement-breakpoint
CREATE TYPE "public"."roles" AS ENUM('user', 'technician', 'coordinator', 'admin');--> statement-breakpoint
CREATE TYPE "public"."technician_speciality" AS ENUM('Electricidad', 'Refrigeracion', 'Iluminacion', 'Pintura', 'Protocolo', 'IT');--> statement-breakpoint

CREATE TABLE "Brand" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	CONSTRAINT "Brand_name_unique" UNIQUE("name")
);
--> statement-breakpoint

CREATE TABLE "Equipment" (
	"uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"technicalCode" text NOT NULL,
	"name" text NOT NULL,
	"serialNumber" text NOT NULL,
	"description" text,
	"state" "equipment_state" DEFAULT 'en_inventario' NOT NULL,
	"dependsOn" uuid,
	"brandId" integer NOT NULL,
	"technicalLocation" text,
	"transferLocation" text,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp,
	CONSTRAINT "Equipment_technicalCode_unique" UNIQUE("technicalCode"),
	CONSTRAINT "Equipment_serialNumber_unique" UNIQUE("serialNumber")
);
--> statement-breakpoint
CREATE TABLE "Equipment_operational_location" (
	"equipmentUuid" uuid NOT NULL,
	"locationTechnicalCode" text NOT NULL,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp,
	CONSTRAINT "Equipment_operational_location_equipmentUuid_locationTechnicalCode_pk" PRIMARY KEY("equipmentUuid","locationTechnicalCode")
);
--> statement-breakpoint
CREATE TABLE "Report" (
	"id" serial PRIMARY KEY NOT NULL,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"priority" "report_priority" DEFAULT 'medium' NOT NULL,
	"state" "report_state" DEFAULT 'pending' NOT NULL,
	"type" "report_type" DEFAULT 'preventive' NOT NULL,
	"notes" text,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp
);
--> statement-breakpoint
CREATE TABLE "Report_Origin" (
	"id" serial PRIMARY KEY NOT NULL,
	"emailRemitent" text,
	"GEMAcreator" uuid,
	"source" "Report_Origin_Source" NOT NULL,
	"description" text,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp
);
--> statement-breakpoint
CREATE TABLE "Report_Update" (
	"id" serial PRIMARY KEY NOT NULL,
	"description" text NOT NULL,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp
);
--> statement-breakpoint
CREATE TABLE "Technical_location" (
	"technicalCode" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"type" integer NOT NULL,
	"parentTechnicalCode" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "Technical_location_types" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"fields" jsonb,
	"nameTemplate" text NOT NULL,
	"codeTemplate" text NOT NULL,
	CONSTRAINT "Technical_location_types_name_unique" UNIQUE("name"),
	CONSTRAINT "Technical_location_types_nameTemplate_unique" UNIQUE("nameTemplate"),
	CONSTRAINT "Technical_location_types_codeTemplate_unique" UNIQUE("codeTemplate")
);
--> statement-breakpoint
CREATE TABLE "Technical_team" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"speciality" "technician_speciality",
	"leaderId" uuid,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp
);
--> statement-breakpoint
CREATE TABLE "Technician" (
	"uuid" uuid PRIMARY KEY NOT NULL,
	"personalId" text NOT NULL,
	"contact" text NOT NULL,
	"speciality" "technician_speciality" NOT NULL,
	"technicalTeamId" INTEGER NOT NULL,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp,
	CONSTRAINT "Technician_personalId_unique" UNIQUE("personalId")
);
--> statement-breakpoint
CREATE TABLE "User" (
	"uuid" uuid PRIMARY KEY NOT NULL,
	"name" text,
	"email" text NOT NULL,
	"role" "roles" DEFAULT 'user' NOT NULL,
	"updatedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"deletedAt" timestamp,
	CONSTRAINT "User_email_unique" UNIQUE("email")
);
--> statement-breakpoint
ALTER TABLE "Equipment" ADD CONSTRAINT "Equipment_dependsOn_Equipment_uuid_fk" FOREIGN KEY ("dependsOn") REFERENCES "public"."Equipment"("uuid") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment" ADD CONSTRAINT "Equipment_brandId_Brand_id_fk" FOREIGN KEY ("brandId") REFERENCES "public"."Brand"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment" ADD CONSTRAINT "Equipment_technicalLocation_Technical_location_technicalCode_fk" FOREIGN KEY ("technicalLocation") REFERENCES "public"."Technical_location"("technicalCode") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment" ADD CONSTRAINT "Equipment_transferLocation_Technical_location_technicalCode_fk" FOREIGN KEY ("transferLocation") REFERENCES "public"."Technical_location"("technicalCode") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD CONSTRAINT "Equipment_operational_location_equipmentUuid_Equipment_uuid_fk" FOREIGN KEY ("equipmentUuid") REFERENCES "public"."Equipment"("uuid") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Equipment_operational_location" ADD CONSTRAINT "Equipment_operational_location_locationTechnicalCode_Technical_location_technicalCode_fk" FOREIGN KEY ("locationTechnicalCode") REFERENCES "public"."Technical_location"("technicalCode") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Report_Origin" ADD CONSTRAINT "Report_Origin_GEMAcreator_User_uuid_fk" FOREIGN KEY ("GEMAcreator") REFERENCES "public"."User"("uuid") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "Technical_location" ADD CONSTRAINT "Technical_location_type_Technical_location_types_id_fk" FOREIGN KEY ("type") REFERENCES "public"."Technical_location_types"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technical_location" ADD CONSTRAINT "Technical_location_parentTechnicalCode_Technical_location_technicalCode_fk" FOREIGN KEY ("parentTechnicalCode") REFERENCES "public"."Technical_location"("technicalCode") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technical_team" ADD CONSTRAINT "Technical_team_leaderId_Technician_uuid_fk" FOREIGN KEY ("leaderId") REFERENCES "public"."Technician"("uuid") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technician" ADD CONSTRAINT "Technician_uuid_User_uuid_fk" FOREIGN KEY ("uuid") REFERENCES "public"."User"("uuid") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "Technician" ADD CONSTRAINT "Technician_technicalTeamId_Technical_team_id_fk" FOREIGN KEY ("technicalTeamId") REFERENCES "public"."Technical_team"("id") ON DELETE set null ON UPDATE cascade;