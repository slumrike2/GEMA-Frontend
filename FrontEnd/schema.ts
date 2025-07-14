import {
	uuid,
	integer,
	pgTable,
	serial,
	text,
	timestamp,
	pgEnum
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm/sql/sql';

export const timestamps = {
	updatedAt: timestamp(),
	createdAt: timestamp().defaultNow().notNull(),
	deletedAt: timestamp()
};

export const rolesEnum = pgEnum('roles', [
	'user',
	'technician',
	'coordinator',
	'admin'
]);

export const User = pgTable('User', {
	uuid: uuid().primaryKey(),
	name: text().notNull(),
	email: text().notNull().unique(),
	role: rolesEnum().notNull().default('user'),
	...timestamps
});

export const TechnicianSpecialities = pgTable('Technician_specialties', {
	codeName: text().primaryKey(),
	description: text()
});

export const Technician = pgTable('Technician', {
	uuid: uuid()
		.primaryKey()
		.references(() => User.uuid, {
			onDelete: 'cascade',
			onUpdate: 'cascade'
		}),
	personalId: text().notNull().unique(),
	contact: text().notNull(),
	speciality: text()
		.notNull()
		.references(() => TechnicianSpecialities.codeName, {
			onDelete: 'cascade',
			onUpdate: 'cascade'
		}),
	...timestamps
});

export const TechnicalTeam = pgTable('Technical_team', {
	id: serial().primaryKey(),
	name: text().notNull(),
	speciality: text().references(() => TechnicianSpecialities.codeName, {
		onDelete: 'cascade',
		onUpdate: 'cascade'
	}),
	...timestamps
});

export const TechnicalLocationTypes = pgTable('Technical_location_types', {
	id: serial().primaryKey(),
	name: text().notNull().unique(),
	description: text(),
	nameTemplate: text().notNull().unique(),
	codeTemplate: text().notNull().unique()
});

export const TechnicalLocation = pgTable('Technical_location', {
	technicalCode: text().primaryKey(),
	name: text().notNull(),
	type: serial()
		.notNull()
		.references(() => TechnicalLocationTypes.id, {
			onDelete: 'cascade',
			onUpdate: 'cascade'
		}),
	parentTechnicalCode: text()
		.notNull()
		.references(() => TechnicalLocation.technicalCode, {
			onDelete: 'cascade',
			onUpdate: 'cascade'
		})
});

export const EquipmentStateEnum = pgEnum('equipment_state', [
	'installed',
	'in_maintenance',
	'maintenance_pending',
	'in_repair',
	'repair_pending',
	'in_stock',
	'decommissioned',
	'transfer_pending'
]);

export const Brand = pgTable('Brand', {
	id: serial().primaryKey(),
	name: text().notNull().unique()
});

export const Equipment = pgTable('Equipment', {
	uuid: uuid()
		.primaryKey()
		.default(sql`gen_random_uuid()`),
	technicalCode: text().notNull().unique(),
	name: text().notNull(),
	serialNumber: text().notNull().unique(),
	description: text(),
	state: EquipmentStateEnum().notNull().default('in_stock'),
	dependsOn: uuid().references(() => Equipment.uuid, {
		onDelete: 'set null',
		onUpdate: 'cascade'
	}),
	brandId: serial()
		.notNull()
		.references(() => Brand.id, {
			onDelete: 'cascade',
			onUpdate: 'cascade'
		}),
	technicalLocation: text().references(() => TechnicalLocation.technicalCode, {
		onDelete: 'set null',
		onUpdate: 'cascade'
	}),
	transferLocation: text().references(() => TechnicalLocation.technicalCode, {
		onDelete: 'set null',
		onUpdate: 'cascade'
	}),
	...timestamps
});

export const EquipmentOperationalLocation = pgTable(
	'Equipment_operational_location',
	{
		equipmentUuid: uuid()
			.notNull()
			.references(() => Equipment.uuid, {
				onDelete: 'cascade',
				onUpdate: 'cascade'
			})
			.primaryKey(),
		locationTechnicalCode: text()
			.notNull()
			.references(() => TechnicalLocation.technicalCode, {
				onDelete: 'set null',
				onUpdate: 'cascade'
			})
			.primaryKey(),
		...timestamps
	}
);

export const ReportOriginSourceEnum = pgEnum('Report_Origin_Source', [
	'email',
	'managementSystem',
	'chat',
	'GEMA'
]);

export const ReportOrigin = pgTable('Report_Origin', {
	id: serial().primaryKey(),
	emailRemitent: text(),
	GEMAcreator: uuid().references(() => User.uuid),
	source: ReportOriginSourceEnum().notNull(),
	description: text(),
	...timestamps
});

export const reportPriorityEnum = pgEnum('report_priority', [
	'high',
	'medium',
	'low'
]);

export const reportTypeEnum = pgEnum('report_type', ['preventive', 'active']);

export const reportStateEnum = pgEnum('report_state', [
	'pending',
	'programmed',
	'in_progress',
	'solved',
	'cancelled'
]);

export const Report = pgTable('Report', {
	id: serial().primaryKey(),
	title: text().notNull(),
	description: text().notNull(),
	priority: reportPriorityEnum().notNull().default('medium'),
	state: reportStateEnum().notNull().default('pending'),
	type: reportTypeEnum().notNull().default('preventive'),
	notes: text(),
	...timestamps
});

export const ReportUpdate = pgTable('Report_Update', {
	id: serial().primaryKey(),
	description: text().notNull(),
	...timestamps
});
