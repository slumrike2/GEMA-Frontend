/**
 * @fileoverview Rutas para la gestión de ubicaciones técnicas
 * 
 * Este archivo define todas las rutas HTTP relacionadas con la gestión
 * de ubicaciones técnicas del sistema GEMA. Incluye operaciones CRUD básicas
 * y funcionalidades específicas para el manejo de ubicaciones jerárquicas.
 * 
 * Base URL: /api/technical-locations
 * 
 * Endpoints disponibles:
 * - GET /api/technical-locations - Obtener todas las ubicaciones técnicas
 * - GET /api/technical-locations/:technicalCode - Obtener ubicación por código técnico
 * - POST /api/technical-locations - Crear nueva ubicación técnica
 * - PUT /api/technical-locations/:technicalCode - Actualizar ubicación técnica
 * - DELETE /api/technical-locations/:technicalCode - Eliminar ubicación técnica
 * - GET /api/technical-locations/:technicalCode/children - Obtener ubicaciones hijas
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import express from 'express';
import { Router } from 'express';
import { technicalLocationController } from '../controllers/technicalLocation.controller';

// Creación del router de Express para las rutas de ubicaciones técnicas
const technicalRouter = Router();

/**
 * GET /api/technical-locations
 * 
 * Obtiene todas las ubicaciones técnicas registradas en el sistema.
 * 
 * Respuesta exitosa (200):
 * - Array con todas las ubicaciones técnicas y sus datos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
technicalRouter.get('/', technicalLocationController.getAll);

/**
 * GET /api/technical-locations/:technicalCode
 * 
 * Obtiene una ubicación técnica específica por su código técnico.
 * 
 * Parámetros de URL:
 * - technicalCode: Código técnico único de la ubicación
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos de la ubicación o null si no existe
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
technicalRouter.get('/:technicalCode', technicalLocationController.getByPk);

/**
 * POST /api/technical-locations
 * 
 * Crea una nueva ubicación técnica en el sistema con generación automática
 * del código técnico basado en el código del padre.
 * 
 * Body requerido:
 * {
 *   "parentTechnicalCode": "string",  // Código técnico de la ubicación padre
 *   "code": "string",                 // Código adicional para generar el código técnico
 *   "name": "string",                 // Nombre de la ubicación
 *   "type": "number"                  // ID del tipo de ubicación
 * }
 * 
 * El código técnico final se genera como: {parentTechnicalCode}-{code}
 * 
 * Respuesta exitosa (201):
 * - Objeto con los datos de la ubicación creada
 * 
 * Respuesta de error (400):
 * - Error si faltan parentTechnicalCode o code
 * - Errores de validación si los datos no son válidos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
technicalRouter.post('/', technicalLocationController.insert);

/**
 * PUT /api/technical-locations/:technicalCode
 * 
 * Actualiza una ubicación técnica existente por su código técnico.
 * 
 * Parámetros de URL:
 * - technicalCode: Código técnico único de la ubicación a actualizar
 * 
 * Body requerido:
 * {
 *   "name": "string",                 // Nuevo nombre de la ubicación
 *   "type": "number",                 // Nuevo ID del tipo de ubicación
 *   "parentTechnicalCode": "string"   // Nuevo código técnico del padre
 * }
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos de la ubicación actualizada
 * 
 * Respuesta de error (400):
 * - Errores de validación si los datos no son válidos
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
technicalRouter.put('/:technicalCode', technicalLocationController.update);

/**
 * DELETE /api/technical-locations/:technicalCode
 * 
 * Elimina una ubicación técnica del sistema por su código técnico.
 * 
 * Parámetros de URL:
 * - technicalCode: Código técnico único de la ubicación a eliminar
 * 
 * Respuesta exitosa (200):
 * - Objeto con los datos de la ubicación eliminada
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 */
technicalRouter.delete('/:technicalCode', technicalLocationController.delete);

/**
 * GET /api/technical-locations/:technicalCode/children
 * 
 * Obtiene todas las ubicaciones hijas de una ubicación específica.
 * Esta ruta permite navegar la jerarquía de ubicaciones técnicas.
 * 
 * Parámetros de URL:
 * - technicalCode: Código técnico de la ubicación padre
 * 
 * Respuesta exitosa (200):
 * - Array con todas las ubicaciones hijas (excluye la ubicación padre)
 * 
 * Respuesta de error (500):
 * - Mensaje de error si hay problemas con la base de datos
 * 
 * Nota: Esta consulta excluye la ubicación padre de los resultados
 * para evitar referencias circulares, especialmente importante para
 * la ubicación raíz (Sede) que no tiene padre.
 */
technicalRouter.get('/:technicalCode/children', technicalLocationController.getChildrenByTechnicalCode);

export default technicalRouter;
