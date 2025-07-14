/**
 * @fileoverview Rutas para la gestión de reportes
 * 
 * Este archivo define todas las rutas HTTP relacionadas con la gestión
 * de reportes del sistema GEMA. Cada ruta está mapeada a su correspondiente
 * función del controlador de reportes.
 * 
 * Base URL: /api/reports
 * 
 * Endpoints disponibles:
 * - GET /api/reports - Obtener todos los reportes
 * - GET /api/reports/:id - Obtener reporte específico por ID
 * - POST /api/reports - Crear nuevo reporte
 * - PUT /api/reports/:id - Actualizar reporte existente
 * - DELETE /api/reports/:id - Eliminar reporte
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { Router } from 'express';
import { reportController } from '../controllers/report.controller';

// Creación del router de Express para las rutas de reportes
const router = Router();

/**
 * GET /api/reports
 * 
 * Obtiene todos los reportes registrados en el sistema.
 * 
 * Respuesta exitosa (200):
 * - Array con todos los reportes y sus datos completos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.get('/', reportController.getAll);

/**
 * GET /api/reports/:id
 * 
 * Obtiene un reporte específico por su ID.
 * 
 * Parámetros de URL:
 * - id: Identificador único del reporte
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos del reporte o null si no existe
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.get('/:id', reportController.getByPk);

/**
 * POST /api/reports
 * 
 * Crea un nuevo reporte en el sistema.
 * 
 * Body requerido:
 * {
 *   "title": "string",                // Título del reporte
 *   "description": "string",          // Descripción detallada del reporte
 *   "priority": "string",             // Prioridad del reporte (high, medium, low) - opcional
 *   "state": "string",                // Estado del reporte (pending, programmed, in_progress, solved, cancelled) - opcional
 *   "type": "string",                 // Tipo de reporte (preventive, active) - opcional
 *   "notes": "string"                 // Notas adicionales opcionales
 * }
 * 
 * Respuesta exitosa (201):
 * - Objeto con los datos del reporte creado
 * 
 * Respuesta de error (400):
 * - Errores de validación si los datos no son válidos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.post('/', reportController.insert);

/**
 * PUT /api/reports/:id
 * 
 * Actualiza un reporte existente por su ID.
 * 
 * Parámetros de URL:
 * - id: Identificador único del reporte a actualizar
 * 
 * Body requerido:
 * {
 *   "title": "string",                // Nuevo título del reporte
 *   "description": "string",          // Nueva descripción detallada del reporte
 *   "priority": "string",             // Nueva prioridad del reporte (high, medium, low) - opcional
 *   "state": "string",                // Nuevo estado del reporte (pending, programmed, in_progress, solved, cancelled) - opcional
 *   "type": "string",                 // Nuevo tipo de reporte (preventive, active) - opcional
 *   "notes": "string"                 // Nuevas notas adicionales opcionales
 * }
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos del reporte actualizado
 * 
 * Respuesta de error (400):
 * - Errores de validación si los datos no son válidos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.put('/:id', reportController.update);

/**
 * DELETE /api/reports/:id
 * 
 * Elimina un reporte del sistema por su ID.
 * 
 * Parámetros de URL:
 * - id: Identificador único del reporte a eliminar
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos del reporte eliminado
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
router.delete('/:id', reportController.delete);

export default router;
