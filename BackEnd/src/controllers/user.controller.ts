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
export const userController = createCrud({
	table: User, // Tabla de usuarios en la base de datos
	validationSchema: UserSchema, // Esquema de validación para usuarios
	objectName: 'User' // Nombre del objeto para mensajes de error
});
