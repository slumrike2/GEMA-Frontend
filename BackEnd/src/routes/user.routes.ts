/**
 * @fileoverview Rutas para la gestión de usuarios
 * 
 * Este archivo define todas las rutas HTTP relacionadas con la gestión
 * de usuarios del sistema GEMA. Cada ruta está mapeada a su correspondiente
 * función del controlador de usuarios.
 * 
 * Base URL: /api/users
 * 
 * Endpoints disponibles:
 * - GET /api/users - Obtener todos los usuarios
 * - GET /api/users/:uuid - Obtener usuario específico por UUID
 * - POST /api/users - Crear nuevo usuario
 * - PUT /api/users/:uuid - Actualizar usuario existente
 * - DELETE /api/users/:uuid - Eliminar usuario
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { Router } from 'express';
import { userController } from '../controllers/user.controller';

// Creación del router de Express para las rutas de usuarios
const router = Router();

/**
 * GET /api/users
 * 
 * Obtiene todos los usuarios registrados en el sistema.
 * 
 * Respuesta exitosa (200):
 * - Array con todos los usuarios y sus datos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.get('/', userController.getAll);

/**
 * GET /api/users/:uuid
 * 
 * Obtiene un usuario específico por su UUID.
 * 
 * Parámetros de URL:
 * - uuid: Identificador único del usuario
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos del usuario o null si no existe
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.get('/:uuid', userController.getByPk);

/**
 * POST /api/users
 * 
 * Crea un nuevo usuario en el sistema.
 * 
 * Body requerido:
 * {
 *   "name": "string",     // Nombre del usuario (mínimo 1 carácter)
 *   "email": "string",    // Email válido y único
 *   "role": "string"      // Rol opcional (user, technician, coordinator, admin)
 * }
 * 
 * Respuesta exitosa (201):
 * - Objeto con los datos del usuario creado
 * 
 * Respuesta de error (400):
 * - Errores de validación si los datos no son válidos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.post('/', userController.insert);

/**
 * PUT /api/users/:uuid
 * 
 * Actualiza un usuario existente por su UUID.
 * 
 * Parámetros de URL:
 * - uuid: Identificador único del usuario a actualizar
 * 
 * Body requerido:
 * {
 *   "name": "string",     // Nuevo nombre del usuario (mínimo 1 carácter)
 *   "email": "string",    // Nuevo email válido y único
 *   "role": "string"      // Nuevo rol opcional (user, technician, coordinator, admin)
 * }
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos del usuario actualizado
 * 
 * Respuesta de error (400):
 * - Errores de validación si los datos no son válidos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.put('/:uuid', userController.update);

/**
 * DELETE /api/users/:uuid
 * 
 * Elimina un usuario del sistema por su UUID.
 * 
 * Parámetros de URL:
 * - uuid: Identificador único del usuario a eliminar
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos del usuario eliminado
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.delete('/:uuid', userController.delete);

export default router;
