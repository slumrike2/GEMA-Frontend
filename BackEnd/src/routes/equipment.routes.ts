/**
 * @fileoverview Rutas para la gestión de equipos
 *
 * Este archivo define todas las rutas HTTP relacionadas con la gestión
 * de equipos del sistema GEMA. Cada ruta está mapeada a su correspondiente
 * función del controlador de equipos.
 *
 * Base URL: /api/equipment
 *
 * Endpoints disponibles:
 * - GET /api/equipment - Obtener todos los equipos
 * - GET /api/equipment/:uuid - Obtener equipo específico por UUID
 * - POST /api/equipment - Crear nuevo equipo
 * - PUT /api/equipment/:uuid - Actualizar equipo existente
 * - DELETE /api/equipment/:uuid - Eliminar equipo
 *
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { Router } from 'express';
import { equipmentController } from '../controllers/equipment.controller';

// Creación del router de Express para las rutas de equipos
const router = Router();

router.get(
	'/operationalLocation/:equipmentId',
	equipmentController.getEquipmentOperationalLocations
);

router.put(
	'/assign/technicalLocation/:equipmentId/:technicalLocationId',
	equipmentController.assignTechnicalLocation
);

router.put(
	'/assign/operationalLocation/:equipmentId/:operationalLocationId',
	equipmentController.assignOperationalLocation
);

router.put(
	'/transfer/:equipmentId/:transferLocationId',
	equipmentController.setTransfer
);

/**
 * GET /api/equipment
 *
 * Obtiene todos los equipos registrados en el sistema.
 *
 * Respuesta exitosa (200):
 * - Array con todos los equipos y sus datos completos
 *
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.get('/', equipmentController.getAll);

/**
 * GET /api/equipment/:uuid
 *
 * Obtiene un equipo específico por su UUID.
 *
 * Parámetros de URL:
 * - uuid: Identificador único del equipo
 *
 * Respuesta exitosa (200):
 * - Objeto con los datos del equipo o null si no existe
 *
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.get('/:uuid', equipmentController.getByPk);

/**
 * POST /api/equipment
 *
 * Crea un nuevo equipo en el sistema.
 *
 * Body requerido:
 * {
 *   "technicalCode": "string",        // Código técnico único del equipo
 *   "name": "string",                 // Nombre del equipo
 *   "serialNumber": "string",         // Número de serie único del equipo
 *   "description": "string",          // Descripción opcional del equipo
 *   "state": "string",                // Estado del equipo (opcional)
 *   "dependsOn": "string",            // UUID del equipo del que depende (opcional)
 *   "brandId": "number",              // ID de la marca del equipo
 *   "technicalLocation": "string",    // Código de ubicación técnica (opcional)
 *   "transferLocation": "string"      // Código de ubicación de transferencia (opcional)
 * }
 *
 * Respuesta exitosa (201):
 * - Objeto con los datos del equipo creado
 *
 * Respuesta de error (400):
 * - Errores de validación si los datos no son válidos
 *
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.post('/', equipmentController.insert);

/**
 * PUT /api/equipment/:uuid
 *
 * Actualiza un equipo existente por su UUID.
 *
 * Parámetros de URL:
 * - uuid: Identificador único del equipo a actualizar
 *
 * Body requerido:
 * {
 *   "technicalCode": "string",        // Nuevo código técnico único del equipo
 *   "name": "string",                 // Nuevo nombre del equipo
 *   "serialNumber": "string",         // Nuevo número de serie único del equipo
 *   "description": "string",          // Nueva descripción opcional del equipo
 *   "state": "string",                // Nuevo estado del equipo (opcional)
 *   "dependsOn": "string",            // Nuevo UUID del equipo del que depende (opcional)
 *   "brandId": "number",              // Nuevo ID de la marca del equipo
 *   "technicalLocation": "string",    // Nuevo código de ubicación técnica (opcional)
 *   "transferLocation": "string"      // Nuevo código de ubicación de transferencia (opcional)
 * }
 *
 * Respuesta exitosa (200):
 * - Objeto con los datos del equipo actualizado
 *
 * Respuesta de error (400):
 * - Errores de validación si los datos no son válidos
 *
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.put('/:uuid', equipmentController.update);

/**
 * DELETE /api/equipment/:uuid
 *
 * Elimina un equipo del sistema por su UUID.
 *
 * Parámetros de URL:
 * - uuid: Identificador único del equipo a eliminar
 *
 * Respuesta exitosa (200):
 * - Objeto con los datos del equipo eliminado
 *
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.delete('/:uuid', equipmentController.delete);

export default router;
