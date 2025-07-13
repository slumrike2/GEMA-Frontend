/**
 * @fileoverview Esquemas de validación para GEMA Backend
 * 
 * Este archivo define todos los esquemas de validación usando Zod para
 * validar los datos de entrada en las operaciones CRUD. Cada esquema
 * corresponde a una tabla de la base de datos y define las reglas de
 * validación para cada campo.
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { z } from 'zod';

/**
 * Esquema de validación para tipos de ubicación técnica
 * 
 * Valida los datos requeridos para crear o actualizar un tipo de ubicación:
 * - name: Nombre del tipo (3-50 caracteres)
 * - description: Descripción opcional
 * - nameTemplate: Plantilla para nombres (3-50 caracteres)
 * - codeTemplate: Plantilla para códigos (3-50 caracteres)
 */
export const LocationTypeSchema = z.object({
	name: z.string().min(3).max(50),
	description: z.string().optional(),
	nameTemplate: z.string().min(3).max(50),
	codeTemplate: z.string().min(3).max(50)
});

/**
 * Esquema de validación para usuarios
 * 
 * Valida los datos requeridos para crear o actualizar un usuario:
 * - uuid: UUID opcional (generado automáticamente si no se proporciona)
 * - name: Nombre del usuario (mínimo 1 carácter)
 * - email: Email válido del usuario
 * - role: Rol del usuario (opcional, por defecto 'user')
 * - timestamps: Campos de timestamp opcionales
 */
export const UserSchema = z.object({
	uuid: z.string().uuid().optional(),
	name: z.string().min(1),
	email: z.string().email(),
	role: z.enum(['user', 'technician', 'coordinator', 'admin']).optional(),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});

// Esquema comentado para especialidades de técnicos (reemplazado por enum)
// export const TechnicianSpecialitiesSchema = z.object({
//   codeName: z.string().min(1),
//   description: z.string().optional()
// });

/**
 * Enum de validación para especialidades de técnicos
 * 
 * Define las especialidades válidas que puede tener un técnico:
 * - Electricista: Especialidad en trabajos eléctricos
 * - Mecanica: Especialidad en trabajos mecánicos
 * - Logistica: Especialidad en logística y transporte
 * - Electronica: Especialidad en trabajos electrónicos
 */
export const technicianSpecialityEnum = z.enum([
	'Electricista',
	'Mecanica',
	'Logistica',
	'Electronica'
]);

/**
 * Esquema de validación para técnicos
 * 
 * Valida los datos requeridos para crear o actualizar un técnico:
 * - uuid: UUID opcional (referencia al usuario)
 * - personalId: Identificación personal única
 * - contact: Información de contacto
 * - speciality: Especialidad del técnico
 * - technicalTeamId: ID del equipo técnico (opcional)
 * - timestamps: Campos de timestamp opcionales
 */
export const TechnicianSchema = z.object({
	uuid: z.string().uuid().optional(),
	personalId: z.string().min(1),
	contact: z.string().min(1),
	speciality: technicianSpecialityEnum,
	technicalTeamId: z.number().int().optional(),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});

/**
 * Esquema de validación para equipos técnicos
 * 
 * Valida los datos requeridos para crear o actualizar un equipo técnico:
 * - id: ID opcional (generado automáticamente)
 * - name: Nombre del equipo
 * - speciality: Especialidad del equipo (opcional)
 * - timestamps: Campos de timestamp opcionales
 */
export const TechnicalTeamSchema = z.object({
	id: z.number().int().optional(),
	name: z.string().min(1),
	speciality: technicianSpecialityEnum.optional(),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});

/**
 * Esquema de validación para ubicaciones técnicas
 * 
 * Valida los datos requeridos para crear o actualizar una ubicación técnica:
 * - technicalCode: Código técnico único de la ubicación
 * - name: Nombre de la ubicación
 * - type: ID del tipo de ubicación
 * - parentTechnicalCode: Código técnico de la ubicación padre
 */
export const TechnicalLocationSchema = z.object({
	technicalCode: z.string().min(1),
	name: z.string().min(1),
	type: z.number().int(),
	parentTechnicalCode: z.string().min(1)
});

/**
 * Enum de validación para estados de equipos
 * 
 * Define los estados válidos que puede tener un equipo:
 * - installed: Equipo instalado y operativo
 * - in_maintenance: Equipo en mantenimiento
 * - maintenance_pending: Mantenimiento pendiente
 * - in_repair: Equipo en reparación
 * - repair_pending: Reparación pendiente
 * - in_stock: Equipo en inventario
 * - decommissioned: Equipo descomisionado
 * - transfer_pending: Transferencia pendiente
 */
export const EquipmentStateEnumSchema = z.enum([
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
 * Esquema de validación para marcas
 * 
 * Valida los datos requeridos para crear o actualizar una marca:
 * - id: ID opcional (generado automáticamente)
 * - name: Nombre único de la marca
 */
export const BrandSchema = z.object({
	id: z.number().int().optional(),
	name: z.string().min(1)
});

/**
 * Esquema de validación para equipos
 * 
 * Valida los datos requeridos para crear o actualizar un equipo:
 * - uuid: UUID opcional (generado automáticamente)
 * - technicalCode: Código técnico único del equipo
 * - name: Nombre del equipo
 * - serialNumber: Número de serie único del equipo
 * - description: Descripción opcional del equipo
 * - state: Estado del equipo (opcional)
 * - dependsOn: UUID del equipo del que depende (opcional)
 * - brandId: ID de la marca del equipo
 * - technicalLocation: Código de ubicación técnica (opcional)
 * - transferLocation: Código de ubicación de transferencia (opcional)
 * - timestamps: Campos de timestamp opcionales
 */
export const EquipmentSchema = z.object({
	uuid: z.string().uuid().optional(),
	technicalCode: z.string().min(1),
	name: z.string().min(1),
	serialNumber: z.string().min(1),
	description: z.string().optional(),
	state: EquipmentStateEnumSchema.optional(),
	dependsOn: z.string().uuid().nullable().optional(),
	brandId: z.number().int(),
	technicalLocation: z.string().optional().nullable(),
	transferLocation: z.string().optional().nullable(),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});

/**
 * Esquema de validación para ubicaciones operacionales de equipos
 * 
 * Valida los datos requeridos para crear o actualizar una ubicación operacional:
 * - id: ID opcional (generado automáticamente)
 * - equipmentId: UUID del equipo
 * - locationId: ID de la ubicación
 * - timestamps: Campos de timestamp opcionales
 */
export const EquipmentOperationalLocationSchema = z.object({
	id: z.number().int().optional(),
	equipmentId: z.string().uuid(),
	locationId: z.string().min(1),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});

/**
 * Enum de validación para fuentes de origen de reportes
 * 
 * Define las fuentes válidas desde donde puede originarse un reporte:
 * - email: Reporte originado por email
 * - managementSystem: Reporte originado desde sistema de gestión
 * - chat: Reporte originado por chat
 * - GEMA: Reporte originado desde el sistema GEMA
 */
export const ReportOriginSourceEnumSchema = z.enum([
	'email',
	'managementSystem',
	'chat',
	'GEMA'
]);

/**
 * Esquema de validación para orígenes de reportes
 * 
 * Valida los datos requeridos para crear o actualizar un origen de reporte:
 * - id: ID opcional (generado automáticamente)
 * - emailRemitent: Email del remitente (opcional)
 * - GEMAcreator: UUID del usuario que creó el reporte en GEMA (opcional)
 * - source: Fuente del reporte
 * - description: Descripción opcional del origen
 * - timestamps: Campos de timestamp opcionales
 */
export const ReportOriginSchema = z.object({
	id: z.number().int().optional(),
	emailRemitent: z.string().email().optional(),
	GEMAcreator: z.string().uuid().optional(),
	source: ReportOriginSourceEnumSchema,
	description: z.string().optional(),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});

/**
 * Enums de validación para reportes
 * 
 * Define las opciones válidas para diferentes aspectos de los reportes:
 * - ReportPriorityEnumSchema: Prioridades (high, medium, low)
 * - ReportTypeEnumSchema: Tipos (preventive, active)
 * - ReportStateEnumSchema: Estados (pending, programmed, in_progress, solved, cancelled)
 */
export const ReportPriorityEnumSchema = z.enum(['high', 'medium', 'low']);
export const ReportTypeEnumSchema = z.enum(['preventive', 'active']);
export const ReportStateEnumSchema = z.enum([
	'pending',
	'programmed',
	'in_progress',
	'solved',
	'cancelled'
]);

/**
 * Esquema de validación para reportes
 * 
 * Valida los datos requeridos para crear o actualizar un reporte:
 * - id: ID opcional (generado automáticamente)
 * - title: Título del reporte
 * - description: Descripción detallada del reporte
 * - priority: Prioridad del reporte (opcional, por defecto 'medium')
 * - state: Estado del reporte (opcional, por defecto 'pending')
 * - type: Tipo de reporte (opcional, por defecto 'preventive')
 * - notes: Notas adicionales opcionales
 * - timestamps: Campos de timestamp opcionales
 */
export const ReportSchema = z.object({
	id: z.number().int().optional(),
	title: z.string().min(1),
	description: z.string().min(1),
	priority: ReportPriorityEnumSchema.optional(),
	state: ReportStateEnumSchema.optional(),
	type: ReportTypeEnumSchema.optional(),
	notes: z.string().optional(),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});

/**
 * Esquema de validación para actualizaciones de reportes
 * 
 * Valida los datos requeridos para crear o actualizar una actualización de reporte:
 * - id: ID opcional (generado automáticamente)
 * - description: Descripción de la actualización
 * - timestamps: Campos de timestamp opcionales
 */
export const ReportUpdateSchema = z.object({
	id: z.number().int().optional(),
	description: z.string().min(1),
	updatedAt: z.date().optional(),
	createdAt: z.date().optional(),
	deletedAt: z.date().optional()
});
