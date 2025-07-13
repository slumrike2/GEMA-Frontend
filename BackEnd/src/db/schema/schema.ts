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
	uuid,
	integer,
	pgTable,
	serial,
	text,
	timestamp,
	pgEnum,
	primaryKey
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm/sql/sql';

/**
 * Configuración de timestamps automáticos para todas las tablas
 *
 * - updatedAt: Timestamp de última actualización (se actualiza automáticamente)
 * - createdAt: Timestamp de creación (se establece automáticamente al crear)
 * - deletedAt: Timestamp de eliminación (para soft deletes)
 */
export const timestamps = {
	updatedAt: timestamp(),
	createdAt: timestamp().defaultNow().notNull(),
	deletedAt: timestamp()
};

/**
 * Enum para roles de usuario en el sistema
 *
 * Valores disponibles:
 * - user: Usuario básico del sistema
 * - technician: Técnico con permisos especializados
 * - coordinator: Coordinador con permisos de gestión
 * - admin: Administrador con todos los permisos
 */
export const rolesEnum = pgEnum('roles', [
	'user',
	'technician',
	'coordinator',
	'admin'
]);

/**
 * Tabla de usuarios del sistema
 *
 * Almacena información básica de todos los usuarios incluyendo
 * su rol en el sistema y datos de contacto.
 */
export const User = pgTable('User', {
	uuid: uuid().primaryKey(), // Identificador único del usuario
	name: text().notNull(), // Nombre completo del usuario
	email: text().notNull().unique(), // Email único del usuario
	role: rolesEnum().notNull().default('user'), // Rol del usuario en el sistema
	...timestamps // Timestamps automáticos
});

// Tabla comentada de especialidades de técnicos (reemplazada por enum)
// export const TechnicianSpecialities = pgTable('Technician_specialties', {
// 	codeName: text().primaryKey(),
// 	description: text()
// });

/**
 * Enum para especialidades de técnicos
 *
 * Define las especialidades disponibles para los técnicos:
 * - Electricidad: Especialidad en sistemas eléctricos
 * - Refrigeracion: Especialidad en sistemas de refrigeración
 * - Iluminacion: Especialidad en sistemas de iluminación
 * - Pintura: Especialidad en trabajos de pintura
 * - Protocolo: Especialidad en protocolos y procedimientos
 * - IT: Especialidad en tecnologías de la información
 */
export const technicianSpecialityEnum = pgEnum('technician_speciality', [
	'Electricidad',
	'Refrigeracion',
	'Iluminacion',
	'Pintura',
	'Protocolo',
	'IT'
]);

/**
 * Tabla de técnicos del sistema
 *
 * Extiende la información de usuarios con datos específicos de técnicos
 * como identificación personal, contacto y especialidad.
 */
export const Technician = pgTable('Technician', {
	uuid: uuid()
		.primaryKey()
		.references(() => User.uuid, {
			onDelete: 'cascade', // Si se elimina el usuario, se elimina el técnico
			onUpdate: 'cascade' // Si se actualiza el UUID del usuario, se actualiza aquí
		}),
	personalId: text().notNull().unique(), // Identificación personal única del técnico
	contact: text().notNull(), // Información de contacto del técnico
	speciality: technicianSpecialityEnum().notNull(), // Especialidad del técnico
	// Campo comentado de referencia a especialidades (reemplazado por enum)
	// .references(() => TechnicianSpecialities.codeName, {
	// 	onDelete: 'cascade',
	// 	onUpdate: 'cascade'
	// }),
	technicalTeamId: serial().references(() => TechnicalTeam.id, {
		onDelete: 'set null', // Si se elimina el equipo, el técnico queda sin equipo
		onUpdate: 'cascade' // Si se actualiza el ID del equipo, se actualiza aquí
	}),
	...timestamps // Timestamps automáticos
});

/**
 * Tabla de equipos técnicos
 *
 * Representa grupos de técnicos que trabajan juntos en proyectos
 * o áreas específicas. Puede tener un líder designado.
 */
export const TechnicalTeam = pgTable('Technical_team', {
	id: serial().primaryKey(), // Identificador único del equipo
	name: text().notNull(), // Nombre del equipo técnico
	speciality: technicianSpecialityEnum(), // Especialidad principal del equipo (opcional)
	// Campo comentado de referencia a especialidades (reemplazado por enum)
	// .references(() => TechnicianSpecialities.codeName, {
	// 	onDelete: 'cascade',
	// 	onUpdate: 'cascade'
	// }),
	leaderId: uuid().references(() => Technician.uuid, {
		onDelete: 'set null', // Si se elimina el líder, el equipo queda sin líder
		onUpdate: 'cascade' // Si se actualiza el UUID del líder, se actualiza aquí
	}),
	...timestamps // Timestamps automáticos
});

/**
 * Tabla de tipos de ubicaciones técnicas
 *
 * Define los diferentes tipos de ubicaciones que pueden existir
 * en el sistema (ej: edificio, piso, sala, etc.)
 */
export const TechnicalLocationTypes = pgTable('Technical_location_types', {
	id: serial().primaryKey(), // Identificador único del tipo
	name: text().notNull().unique(), // Nombre único del tipo de ubicación
	description: text(), // Descripción opcional del tipo
	nameTemplate: text().notNull().unique(), // Plantilla para nombres de ubicaciones de este tipo
	codeTemplate: text().notNull().unique() // Plantilla para códigos de ubicaciones de este tipo
});

/**
 * Tabla de ubicaciones técnicas
 *
 * Representa ubicaciones físicas o lógicas en el sistema
 * con una estructura jerárquica (padre-hijo).
 */
export const TechnicalLocation = pgTable('Technical_location', {
	technicalCode: text().primaryKey(), // Código técnico único de la ubicación
	name: text().notNull(), // Nombre de la ubicación
	type: serial()
		.notNull()
		.references(() => TechnicalLocationTypes.id, {
			onDelete: 'cascade', // Si se elimina el tipo, se eliminan las ubicaciones
			onUpdate: 'cascade' // Si se actualiza el ID del tipo, se actualiza aquí
		}),
	parentTechnicalCode: text()
		.notNull()
		.references(() => TechnicalLocation.technicalCode, {
			onDelete: 'cascade', // Si se elimina la ubicación padre, se eliminan las hijas
			onUpdate: 'cascade' // Si se actualiza el código del padre, se actualiza aquí
		})
});

/**
 * Enum para estados de equipos
 *
 * Define los posibles estados en los que puede estar un equipo:
 * - instalado: Equipo instalado y operativo
 * - en_mantenimiento: Equipo en proceso de mantenimiento
 * - mantenimiento_pendiente: Mantenimiento programado pero no iniciado
 * - en_reparaciones: Equipo en proceso de reparación
 * - reparaciones_pendientes: Reparación programada pero no iniciada
 * - en_inventario: Equipo almacenado en inventario
 * - descomisionado: Equipo retirado del servicio
 * - transferencia_pendiente: Equipo en proceso de transferencia
 */
export const EquipmentStateEnum = pgEnum('equipment_state', [
	'instalado',
	'en_mantenimiento',
	'mantenimiento_pendiente',
	'en_reparaciones',
	'reparaciones_pendientes',
	'en_inventario',
	'descomisionado',
	'transferencia_pendiente'
]);

/**
 * Tabla de marcas de equipos
 *
 * Almacena las diferentes marcas de equipos disponibles en el sistema.
 */
export const Brand = pgTable('Brand', {
	id: serial().primaryKey(), // Identificador único de la marca
	name: text().notNull().unique() // Nombre único de la marca
});

/**
 * Tabla de equipos
 *
 * Representa todos los equipos del sistema con su información
 * técnica, ubicación y estado actual.
 */
export const Equipment = pgTable('Equipment', {
	uuid: uuid()
		.primaryKey()
		.default(sql`gen_random_uuid()`), // UUID generado automáticamente
	technicalCode: text().notNull().unique(), // Código técnico único del equipo
	name: text().notNull(), // Nombre del equipo
	serialNumber: text().notNull().unique(), // Número de serie único del equipo
	description: text(), // Descripción opcional del equipo
	state: EquipmentStateEnum().notNull().default('en_inventario'), // Estado actual del equipo
	dependsOn: uuid().references(() => Equipment.uuid, {
		onDelete: 'set null', // Si se elimina el equipo dependiente, se elimina la referencia
		onUpdate: 'cascade' // Si se actualiza el UUID del equipo dependiente, se actualiza aquí
	}),
	brandId: serial()
		.notNull()
		.references(() => Brand.id, {
			onDelete: 'cascade', // Si se elimina la marca, se eliminan los equipos
			onUpdate: 'cascade' // Si se actualiza el ID de la marca, se actualiza aquí
		}),
	technicalLocation: text().references(() => TechnicalLocation.technicalCode, {
		onDelete: 'set null', // Si se elimina la ubicación, el equipo queda sin ubicación
		onUpdate: 'cascade' // Si se actualiza el código de ubicación, se actualiza aquí
	}),
	transferLocation: text().references(() => TechnicalLocation.technicalCode, {
		onDelete: 'set null', // Si se elimina la ubicación de transferencia, se elimina la referencia
		onUpdate: 'cascade' // Si se actualiza el código de ubicación de transferencia, se actualiza aquí
	}),
	...timestamps // Timestamps automáticos
});

/**
 * Tabla de ubicaciones operacionales de equipos
 *
 * Tabla de relación muchos a muchos entre equipos y ubicaciones
 * que permite rastrear el historial de ubicaciones de cada equipo.
 */
export const EquipmentOperationalLocation = pgTable(
	'Equipment_operational_location',
	{
		equipmentUuid: uuid()
			.notNull()
			.references(() => Equipment.uuid, {
				onDelete: 'cascade', // Si se elimina el equipo, se eliminan sus ubicaciones operacionales
				onUpdate: 'cascade' // Si se actualiza el UUID del equipo, se actualiza aquí
			}),
		locationTechnicalCode: text()
			.notNull()
			.references(() => TechnicalLocation.technicalCode, {
				onDelete: 'set null', // Si se elimina la ubicación, se elimina la referencia
				onUpdate: 'cascade' // Si se actualiza el código de ubicación, se actualiza aquí
			}),

		...timestamps // Timestamps automáticos
	},

	(table) => ({
		// Clave primaria compuesta por equipo y ubicación
		pk: primaryKey(table.equipmentUuid, table.locationTechnicalCode)
	})
);

/**
 * Enum para fuentes de origen de reportes
 *
 * Define las diferentes fuentes desde donde pueden originarse los reportes:
 * - email: Reporte originado por email
 * - managementSystem: Reporte originado desde sistema de gestión
 * - chat: Reporte originado por chat
 * - GEMA: Reporte originado desde el sistema GEMA
 */
export const ReportOriginSourceEnum = pgEnum('Report_Origin_Source', [
	'email',
	'managementSystem',
	'chat',
	'GEMA'
]);

/**
 * Tabla de orígenes de reportes
 *
 * Almacena información sobre el origen de cada reporte,
 * incluyendo quién lo creó y desde qué fuente.
 */
export const ReportOrigin = pgTable('Report_Origin', {
	id: serial().primaryKey(), // Identificador único del origen
	emailRemitent: text(), // Email del remitente (si aplica)
	GEMAcreator: uuid().references(() => User.uuid), // Usuario que creó el reporte en GEMA
	source: ReportOriginSourceEnum().notNull(), // Fuente del reporte
	description: text(), // Descripción opcional del origen
	...timestamps // Timestamps automáticos
});

/**
 * Enum para prioridades de reportes
 *
 * Define los niveles de prioridad para los reportes:
 * - high: Prioridad alta
 * - medium: Prioridad media
 * - low: Prioridad baja
 */
export const reportPriorityEnum = pgEnum('report_priority', [
	'high',
	'medium',
	'low'
]);

/**
 * Enum para tipos de reportes
 *
 * Define los tipos de reportes disponibles:
 * - preventive: Reporte preventivo
 * - active: Reporte activo/correctivo
 */
export const reportTypeEnum = pgEnum('report_type', ['preventive', 'active']);

/**
 * Enum para estados de reportes
 *
 * Define los posibles estados de un reporte:
 * - pending: Reporte pendiente de revisión
 * - programmed: Reporte programado para ejecución
 * - in_progress: Reporte en proceso de ejecución
 * - solved: Reporte resuelto/completado
 * - cancelled: Reporte cancelado
 */
export const reportStateEnum = pgEnum('report_state', [
	'pending',
	'programmed',
	'in_progress',
	'solved',
	'cancelled'
]);

/**
 * Tabla de reportes
 *
 * Almacena todos los reportes del sistema con su información
 * básica, prioridad, estado y tipo.
 */
export const Report = pgTable('Report', {
	id: serial().primaryKey(), // Identificador único del reporte
	title: text().notNull(), // Título del reporte
	description: text().notNull(), // Descripción detallada del reporte
	priority: reportPriorityEnum().notNull().default('medium'), // Prioridad del reporte
	state: reportStateEnum().notNull().default('pending'), // Estado actual del reporte
	type: reportTypeEnum().notNull().default('preventive'), // Tipo de reporte
	notes: text(), // Notas adicionales opcionales
	...timestamps // Timestamps automáticos
});

/**
 * Tabla de actualizaciones de reportes
 *
 * Almacena el historial de actualizaciones y comentarios
 * realizados sobre cada reporte.
 */
export const ReportUpdate = pgTable('Report_Update', {
	id: serial().primaryKey(), // Identificador único de la actualización
	description: text().notNull(), // Descripción de la actualización
	...timestamps // Timestamps automáticos
});
