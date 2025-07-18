/**
 * @fileoverview Esquema de la base de datos para GEMA Backend
 *
 * Este archivo define todas las tablas, enums y relaciones de la base de datos
 * usando Drizzle ORM. Incluye la configuración de timestamps automáticos,
 * claves primarias, claves foráneas y restricciones de integridad referencial.
 *
 * @author GEMA Development Team
 * @version 1.0.0
 */

import {
	pgTable,
	foreignKey,
	uuid,
	text,
	timestamp,
	unique,
	serial,
	integer,
	type AnyPgColumn,
	jsonb,
	pgEnum
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

export const reportOriginSource = pgEnum('Report_Origin_Source', [
	'email',
	'managementSystem',
	'chat',
	'GEMA'
]);
export const equipmentState = pgEnum('equipment_state', [
	'instalado',
	'en_mantenimiento',
	'mantenimiento_pendiente',
	'en_reparaciones',
	'reparaciones_pendientes',
	'en_inventario',
	'descomisionado',
	'transferencia_pendiente'
]);
export const reportPriority = pgEnum('report_priority', [
	'high',
	'medium',
	'low'
]);
export const reportState = pgEnum('report_state', [
	'pending',
	'programmed',
	'in_progress',
	'solved',
	'cancelled'
]);
export const reportType = pgEnum('report_type', ['preventive', 'active']);
export const roles = pgEnum('roles', [
	'user',
	'technician',
	'coordinator',
	'admin'
]);
export const technicianSpeciality = pgEnum('technician_speciality', [
	'Electricidad',
	'Refrigeracion',
	'Iluminacion',
	'Pintura',
	'Protocolo',
	'IT'
]);

export const equipmentOperationalLocation = pgTable(
	'Equipment_operational_location',
	{
		equipmentUuid: uuid().notNull(),
		locationTechnicalCode: text().notNull(),
		updatedAt: timestamp({ mode: 'string' }),
		createdAt: timestamp({ mode: 'string' }).defaultNow().notNull(),
		deletedAt: timestamp({ mode: 'string' })
	},
	(table) => [
		foreignKey({
			columns: [table.equipmentUuid],
			foreignColumns: [equipment.uuid],
			name: 'Equipment_operational_location_equipmentUuid_Equipment_uuid_fk'
		})
			.onUpdate('cascade')
			.onDelete('cascade')
	]
);

export const equipment = pgTable(
	'Equipment',
	{
		uuid: uuid().defaultRandom().primaryKey().notNull(),
		technicalCode: text().notNull(),
		name: text().notNull(),
		serialNumber: text().notNull(),
		description: text(),
		state: equipmentState().default('en_inventario').notNull(),
		dependsOn: uuid(),
		brandId: integer().notNull(),
		technicalLocation: text(),
		transferLocation: text(),
		updatedAt: timestamp({ mode: 'string' }),
		createdAt: timestamp({ mode: 'string' }).defaultNow().notNull(),
		deletedAt: timestamp({ mode: 'string' })
	},
	(table) => [
		foreignKey({
			columns: [table.brandId],
			foreignColumns: [brand.id],
			name: 'Equipment_brandId_Brand_id_fk'
		})
			.onUpdate('cascade')
			.onDelete('cascade'),
		foreignKey({
			columns: [table.dependsOn],
			foreignColumns: [table.uuid],
			name: 'Equipment_dependsOn_Equipment_uuid_fk'
		})
			.onUpdate('cascade')
			.onDelete('set null'),
		foreignKey({
			columns: [table.technicalLocation],
			foreignColumns: [technicalLocation.technicalCode],
			name: 'Equipment_technicalLocation_Technical_location_technicalCode_fk'
		})
			.onUpdate('cascade')
			.onDelete('set null'),
		foreignKey({
			columns: [table.transferLocation],
			foreignColumns: [technicalLocation.technicalCode],
			name: 'Equipment_transferLocation_Technical_location_technicalCode_fk'
		})
			.onUpdate('cascade')
			.onDelete('set null'),
		unique('Equipment_technicalCode_unique').on(table.technicalCode),
		unique('Equipment_serialNumber_unique').on(table.serialNumber)
	]
);

export const report = pgTable('Report', {
	id: serial().primaryKey().notNull(),
	title: text().notNull(),
	description: text().notNull(),
	priority: reportPriority().default('medium').notNull(),
	state: reportState().default('pending').notNull(),
	type: reportType().default('preventive').notNull(),
	notes: text(),
	updatedAt: timestamp({ mode: 'string' }),
	createdAt: timestamp({ mode: 'string' }).defaultNow().notNull(),
	deletedAt: timestamp({ mode: 'string' }),
	technicalTeamId: integer()
});

export const brand = pgTable(
	'Brand',
	{
		id: serial().primaryKey().notNull(),
		name: text().notNull()
	},
	(table) => [unique('Brand_name_unique').on(table.name)]
);

export const reportOrigin = pgTable(
	'Report_Origin',
	{
		id: serial().primaryKey().notNull(),
		emailRemitent: text(),
		gemAcreator: uuid('GEMAcreator'),
		source: reportOriginSource().notNull(),
		description: text(),
		updatedAt: timestamp({ mode: 'string' }),
		createdAt: timestamp({ mode: 'string' }).defaultNow().notNull(),
		deletedAt: timestamp({ mode: 'string' })
	},
	(table) => [
		foreignKey({
			columns: [table.gemAcreator],
			foreignColumns: [user.uuid],
			name: 'Report_Origin_GEMAcreator_User_uuid_fk'
		})
	]
);

export const technician = pgTable(
	'Technician',
	{
		uuid: uuid().primaryKey().notNull(),
		personalId: text().notNull(),
		contact: text().notNull(),
		speciality: technicianSpeciality().notNull(),
		updatedAt: timestamp({ mode: 'string' }),
		createdAt: timestamp({ mode: 'string' }).defaultNow().notNull(),
		deletedAt: timestamp({ mode: 'string' }),
		technicalTeamId: integer()
	},
	(table) => [
		foreignKey({
			columns: [table.technicalTeamId],
			foreignColumns: [technicalTeam.id],
			name: 'Technician_technicalTeamId_Technical_team_id_fk'
		})
			.onUpdate('cascade')
			.onDelete('set null'),
		foreignKey({
			columns: [table.uuid],
			foreignColumns: [user.uuid],
			name: 'Technician_uuid_User_uuid_fk'
		})
			.onUpdate('cascade')
			.onDelete('cascade'),
		unique('Technician_personalId_unique').on(table.personalId)
	]
);

export const reportUpdate = pgTable('Report_Update', {
	id: serial().primaryKey().notNull(),
	description: text().notNull(),
	updatedAt: timestamp({ mode: 'string' }),
	createdAt: timestamp({ mode: 'string' }).defaultNow().notNull(),
	deletedAt: timestamp({ mode: 'string' }),
	reportId: integer('report_id').notNull()
});

export const technicalLocationTypes = pgTable(
	'Technical_location_types',
	{
		id: serial().primaryKey().notNull(),
		name: text().notNull(),
		description: text(),
		icon: text().notNull(),
		nameTemplate: text().notNull(),
		codeTemplate: text().notNull(),
		fields: jsonb()
	},
	(table) => [
		unique('Technical_location_types_name_unique').on(table.name),
		unique('Technical_location_types_nameTemplate_unique').on(
			table.nameTemplate
		),
		unique('Technical_location_types_codeTemplate_unique').on(
			table.codeTemplate
		)
	]
);

export const user = pgTable(
	'User',
	{
		uuid: uuid().primaryKey().notNull(),
		name: text(),
		email: text().notNull(),
		role: roles().default('user').notNull(),
		updatedAt: timestamp({ mode: 'string' }),
		createdAt: timestamp({ mode: 'string' }).defaultNow(),
		deletedAt: timestamp({ mode: 'string' })
	},
	(table) => [unique('User_email_unique').on(table.email)]
);

export const technicalTeam = pgTable(
	'Technical_team',
	{
		id: serial().primaryKey().notNull(),
		name: text().notNull(),
		speciality: technicianSpeciality(),
		updatedAt: timestamp({ mode: 'string' }),
		createdAt: timestamp({ mode: 'string' }).defaultNow().notNull(),
		deletedAt: timestamp({ mode: 'string' }),
		leaderId: uuid().notNull()
	},
	(table) => [
		foreignKey({
			columns: [table.leaderId],
			foreignColumns: [technician.uuid],
			name: 'Technical_team_leaderId_Technician_uuid_fk'
		})
			.onUpdate('cascade')
			.onDelete('set null')
	]
);

export const technicalLocation = pgTable(
	'Technical_location',
	{
		technicalCode: text().primaryKey().notNull(),
		abbreviatedTechnicalCode: text().notNull(),
		name: text().notNull(),
		type: integer().notNull(),
		parentTechnicalCode: text()
	},
	(table) => [
		foreignKey({
			columns: [table.type],
			foreignColumns: [technicalLocationTypes.id],
			name: 'Technical_location_type_Technical_location_types_id_fk'
		})
			.onUpdate('cascade')
			.onDelete('cascade')
	]
);
