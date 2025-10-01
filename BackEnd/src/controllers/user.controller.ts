/**
 * @fileoverview Controlador para la gestión de usuarios
 *
 * Este controlador maneja todas las operaciones CRUD relacionadas con usuarios
 * del sistema. Utiliza el factory CRUD genérico para implementar las operaciones
 * básicas de manera consistente.
 *
 * Endpoints disponibles:
 * - GET /api/users - Obtener todos los usuarios
 * - GET /api/users/:uuid - Obtener usuario por UUID
 * - POST /api/users - Crear nuevo usuario
 * - PUT /api/users/:uuid - Actualizar usuario
 * - DELETE /api/users/:uuid - Eliminar usuario
 *
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { createCrud } from './crudFactory';
import { technician, user } from '../db/schema/schema';
import { userSchema } from '../db/schema/validationSchema';
import { Request, Response } from 'express';
import { db } from '../db';
import { sendWelcomeEmail } from '../utils/mailer';
import { eq, isNull } from 'drizzle-orm';

/**
 * Controlador de usuarios creado usando el factory CRUD
 *
 * Proporciona todas las operaciones CRUD básicas para la tabla User:
 * - insert: Crea nuevos usuarios con validación automática
 * - getByPk: Obtiene usuarios por su UUID
 * - getAll: Obtiene todos los usuarios del sistema
 * - update: Actualiza información de usuarios existentes
 * - delete: Elimina usuarios del sistema
 *
 * Todas las operaciones incluyen:
 * - Validación automática usando UserSchema
 * - Manejo de errores estandarizado
 * - Logging para debugging
 * - Respuestas HTTP apropiadas
 */
const baseUserController = createCrud({
	table: user, // Tabla de usuarios en la base de datos
	validationSchema: userSchema, // Esquema de validación para usuarios
	objectName: 'User' // Nombre del objeto para mensajes de error
});

export const userController = {
	...baseUserController,

	async createWithEmail(req: Request, res: Response): Promise<void> {
		const { uuid, email, role, password } = req.body;

		try {
			const result = await db
				.insert(user)
				.values({ uuid, email, role })
				.returning();
			console.log('Antes de enviar correo');
			await sendWelcomeEmail(email, password);
			console.log('Después de enviar correo');
			res.status(200).json(result[0]);
		} catch (error) {
			console.error('[User] createWithEmail error:', error);
			res.status(500).json({
				error: 'Error creating new user',
				details: (error as any)?.message ?? 'Unknown error'
			});
		}
	},

	// Extensión: obtener usuarios "disponibles" (no asociados a Technician)
	async getAvailable(_req: Request, res: Response): Promise<void> {
		try {
			// Selecciona usuarios cuyo uuid no está en Technician.uuid
			const techs = await db.select({ uuid: technician.uuid }).from(technician);
			const taken = new Set(techs.map((t) => t.uuid));
			const allUsers = await db.select().from(user);
			const available = allUsers.filter((u) => !taken.has(u.uuid));
			res.status(200).json(available);
		} catch (error) {
			console.error('[User] getAvailable error:', error);
			res.status(500).json({
				error: 'Error fetching available users',
				details: (error as any)?.message ?? 'Unknown error'
			});
		}
	}
};
