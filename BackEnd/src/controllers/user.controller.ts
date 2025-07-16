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
import { User } from '../db/schema/schema';
import { UserSchema } from '../db/schema/validationSchema';
import { Request, Response } from 'express';
import { db } from '../db';
import { sendWelcomeEmail } from '../utils/mailer';
import { eq } from 'drizzle-orm';

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
	table: User, // Tabla de usuarios en la base de datos
	validationSchema: UserSchema, // Esquema de validación para usuarios
	objectName: 'User' // Nombre del objeto para mensajes de error
});

export const userController = {
	...baseUserController,

	async createWithEmail(req: Request, res:Response) {
		const {uuid, email, role, password} = req.body;

		try {
			const result = await db
				.insert(User)
				.values({uuid, email, role})
				.returning()
			console.log('Antes de enviar correo');
			await sendWelcomeEmail(email, password)
			console.log('Después de enviar correo');
			res.send(200).json(result[0])
		}
		catch (error) {
			error: 'Error creating new user'
			details: error.message
		}
	},

	async updateName(req: Request, res: Response) {
		const { uuid } = req.params;
		const { name } = req.body;

		if (!name) {
			res.status(400).json({ error: 'El campo name es requerido.' });
		}

		try {
			// Validar que name sea string y no vacío
			if (typeof name !== 'string' || name.trim().length === 0) {
				res.status(400).json({ error: 'El campo name debe ser un string no vacío.' });
			}

			const result = await db
				.update(User)
				.set({ name })
				.where(eq(User.uuid, uuid))
				.returning();

			if (!result[0]) {
				res.status(404).json({ error: 'Usuario no encontrado.' });
			}

			res.status(200).json(result[0]);
		} catch (error) {
			console.error('[User] updateName error:', error);
			res.status(500).json({ error: 'Error actualizando el nombre del usuario', details: error.message });
		}
	},
}

