/**
 * @fileoverview Controlador para la gestión de ubicaciones técnicas
 * 
 * Este controlador maneja todas las operaciones relacionadas con ubicaciones
 * técnicas del sistema. Extiende el factory CRUD básico con funcionalidades
 * específicas para el manejo de ubicaciones jerárquicas.
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

import { db } from '../db';
import { z } from 'zod';
import {
	TechnicalLocation,
	TechnicalLocationTypes,
	Equipment
} from '../db/schema/schema';
import {
	LocationTypeSchema,
	TechnicalLocationSchema
} from '../db/schema/validationSchema';
import { eq, ne, and, isNull } from 'drizzle-orm';
import { Request, Response } from 'express';
import { createCrud } from './crudFactory';

/**
 * Controlador base CRUD para ubicaciones técnicas
 * 
 * Proporciona las operaciones CRUD básicas usando el factory genérico:
 * - getAll: Obtener todas las ubicaciones
 * - getByPk: Obtener ubicación por código técnico
 * - update: Actualizar ubicación existente
 * - delete: Eliminar ubicación
 */
const baseTechnicalLocationController = createCrud({
	table: TechnicalLocation,
	validationSchema: TechnicalLocationSchema,
	objectName: 'TechnicalLocation'
});

/**
 * Controlador completo de ubicaciones técnicas
 * 
 * Extiende el controlador base con funcionalidades específicas para
 * el manejo de ubicaciones jerárquicas y creación de códigos técnicos.
 */
export const technicalLocationController = {
	// Hereda todas las operaciones CRUD básicas del controlador base
	...baseTechnicalLocationController,
	
	/**
	 * Crea una nueva ubicación técnica con generación automática de código
	 * 
	 * Endpoint: POST /api/technical-locations
	 * 
	 * Esta función personalizada maneja la creación de ubicaciones técnicas
	 * con la generación automática del código técnico basado en el código
	 * del padre y un código adicional proporcionado.
	 * 
	 * Parámetros esperados en el body:
	 * - parentTechnicalCode: Código técnico de la ubicación padre
	 * - code: Código adicional para generar el código técnico completo
	 * - name: Nombre de la ubicación
	 * - type: ID del tipo de ubicación
	 * 
	 * El código técnico final se genera como: {parentTechnicalCode}-{code}
	 * 
	 * @param req - Request de Express con los datos de la nueva ubicación
	 * @param res - Response de Express
	 * @returns Ubicación creada con status 201 o error con status apropiado
	 */
	async create(req: Request, res: Response) {
		const { parentTechnicalCode, code, ...rest } = req.body;
		try {
			// Valida que se proporcionen los campos requeridos
			if (!parentTechnicalCode || !code) {
				return res.status(400).json({ 
					error: 'parentTechnicalCode y code son requeridos' 
				});
			}
			
			// Genera el código técnico combinando el padre y el código adicional
			const technicalCode = `${parentTechnicalCode}-${code}`;
			
			// Prepara los datos para la validación
			const data = {
				...rest,
				parentTechnicalCode,
				technicalCode
			};
			
			// Valida los datos usando el esquema de validación
			const validated = TechnicalLocationSchema.parse(data);
			const { technicalCode: tc, name, type, parentTechnicalCode: ptc } = validated;
			
			// Inserta la nueva ubicación en la base de datos
			const result = await db.insert(TechnicalLocation).values({
				technicalCode: tc,
				name,
				type,
				parentTechnicalCode: ptc
			}).returning();
			
			res.status(201).json(result[0]);
		} catch (error) {
			// Maneja errores de validación
			if (error instanceof z.ZodError) {
				res.status(400).json({
					error: 'Validation Error for TechnicalLocation',
					details: error.errors
				});
			} else {
				// Maneja otros errores (base de datos, etc.)
				res.status(500).json({
					error: 'Error inserting data for TechnicalLocation',
					details: error.message
				});
			}
		}
	},

	/**
	 * Obtiene todas las ubicaciones hijas de una ubicación específica
	 * 
	 * Endpoint: GET /api/technical-locations/:technicalCode/children
	 * 
	 * Esta función permite navegar la jerarquía de ubicaciones técnicas
	 * obteniendo todas las ubicaciones que tienen como padre la ubicación
	 * especificada por su código técnico.
	 * 
	 * La consulta excluye la ubicación padre de los resultados para evitar
	 * referencias circulares, especialmente importante para la ubicación raíz
	 * (Sede) que no tiene padre.
	 * 
	 * @param req - Request de Express con el código técnico en los parámetros
	 * @param res - Response de Express
	 * @returns Array de ubicaciones hijas con status 200 o error con status apropiado
	 */
	async getChildrenByTechnicalCode(req: Request, res: Response) {
		const technicalCode = req.params.technicalCode;
		try {
			// Busca todas las ubicaciones que tienen como padre el código especificado
			// y excluye la ubicación padre para evitar referencias circulares
			const result = await db.select()
				.from(TechnicalLocation)
				.where(and(
					eq(TechnicalLocation.parentTechnicalCode, technicalCode),
					ne(TechnicalLocation.technicalCode, technicalCode) // Excluye el mismo codigo de la ubicacion, debido a que la ubicacion Sede no tiene padre
				))
			
			res.status(200).json(result);
		} catch (error) {
			res.status(500).json({error: error.message});
		}
	}
}
