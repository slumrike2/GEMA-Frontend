/**
 * @fileoverview Controlador para la gestión de equipos
 *
 * Este controlador maneja todas las operaciones CRUD relacionadas con equipos,
 * así como operaciones especializadas como la asignación de ubicaciones técnicas
 * y operacionales. Utiliza el factory CRUD genérico para implementar las operaciones
 * básicas de manera consistente y agrega lógica personalizada para relaciones muchos-a-muchos.
 *
 * Endpoints principales:
 * - GET /api/equipment - Obtener todos los equipos
 * - GET /api/equipment/:uuid - Obtener equipo por UUID
 * - POST /api/equipment - Crear nuevo equipo
 * - PUT /api/equipment/:uuid - Actualizar equipo
 * - DELETE /api/equipment/:uuid - Eliminar equipo
 * - POST /api/equipment/assign-technical-location - Asignar ubicación técnica a un equipo
 * - POST /api/equipment/assign-operational-location - Asignar ubicación operacional a un equipo
 *
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { createCrud } from './crudFactory';
import {
	Equipment,
	TechnicalLocation,
	EquipmentOperationalLocation
} from '../db/schema/schema';
import { EquipmentSchema } from '../db/schema/validationSchema';
import { eq, ne, and, isNull } from 'drizzle-orm';
import { Request, Response } from 'express';
import { db } from '../db';

/**
 * Controlador base CRUD para equipos
 *
 * Proporciona las operaciones CRUD básicas usando el factory genérico:
 * - getAll: Obtener todos los equipos
 * - getByPk: Obtener equipo por UUID
 * - insert: Crear nuevo equipo
 * - update: Actualizar equipo existente
 * - delete: Eliminar equipo
 */
const baseEquipmentController = createCrud({
	table: Equipment,
	validationSchema: EquipmentSchema,
	objectName: 'Equipment'
});

/**
 * Controlador completo de equipos
 *
 * Extiende el controlador base con funcionalidades específicas para la gestión
 * de ubicaciones técnicas y operacionales.
 */
export const equipmentController = {
	...baseEquipmentController,

	/**
	 * Asigna una ubicación técnica a un equipo
	 *
	 * Endpoint: PUT /api/equipment/assign/technicalLocation/:equipmentId/:technicalLocationId
	 *
	 * Recibe en los params:
	 * - equipmentId: UUID del equipo
	 * - technicalLocationId: Código técnico de la ubicación
	 *
	 * Actualiza el campo technicalLocation del equipo especificado.
	 *
	 * Responde 200 si la asignación es exitosa, 500 si hay error.
	 */
	async assignTechnicalLocation(req: Request, res: Response) {
		const { equipmentId, technicalLocationId } = req.params;
		try {
			await db
				.update(Equipment)
				.set({ technicalLocation: technicalLocationId })
				.where(eq(Equipment.uuid, equipmentId));
			res
				.status(200)
				.json({ message: 'Equipo asignado a ubicación técnica correctamente' });
		} catch (error) {
			res
				.status(500)
				.json({ message: 'Error al asignar equipo a ubicación técnica' });
		}
	},

	/**
	 * Asigna una ubicación operacional a un equipo (relación muchos-a-muchos)
	 *
	 * Endpoint: POST /api/equipment/assign/operationalLocation/:equipmentId/:operationalLocationId
	 *
	 * Recibe en los params:
	 * - equipmentId: UUID del equipo
	 * - operationalLocationId: Código técnico de la ubicación operacional
	 *
	 * Inserta una nueva relación en la tabla EquipmentOperationalLocation.
	 * Si la relación ya existe, responde 409 (conflicto).
	 *
	 * Responde 201 si la asignación es exitosa, 409 si ya existe, 500 si hay error.
	 */
	async assignOperationalLocation(req: Request, res: Response) {
		const { equipmentId, operationalLocationId } = req.params;
		try {
			// Verificar si ya existe la relación
			const existing = await db
				.select()
				.from(EquipmentOperationalLocation)
				.where(
					and(
						eq(EquipmentOperationalLocation.equipmentUuid, equipmentId),
						eq(
							EquipmentOperationalLocation.locationTechnicalCode,
							operationalLocationId
						)
					)
				);
			if (existing.length > 0) {
				res.status(409).json({
					message: 'La relación equipo-ubicación operacional ya existe'
				});
			}

			// Insertar la nueva relación
			await db.insert(EquipmentOperationalLocation).values({
				equipmentUuid: equipmentId,
				locationTechnicalCode: operationalLocationId
			});
			res.status(201).json({
				message: 'Equipo asignado a ubicación operacional correctamente'
			});
		} catch (error) {
			res
				.status(500)
				.json({ message: 'Error al asignar equipo a ubicación operacional' });
		}
	},

	/**
	 * Actualiza la ubicación de transferencia de un equipo
	 *
	 * Endpoint: PUT /api/equipment/transfer/:equipmentId/:transferLocationId
	 *
	 * Recibe en los params:
	 * - equipmentId: UUID del equipo
	 * - transferLocationId: Código técnico de la ubicación de transferencia
	 *
	 * Responde 200 si la actualización es exitosa, 500 si hay error.
	 */
	async setTransfer(req: Request, res: Response) {
		const { equipmentId, transferLocationId } = req.params;
		try {
			await db
				.update(Equipment)
				.set({ transferLocation: transferLocationId })
				.where(eq(Equipment.uuid, equipmentId));
			res.status(200).json({
				message: 'Ubicación de transferencia actualizada correctamente'
			});
		} catch (error) {
			res
				.status(500)
				.json({ message: 'Error al actualizar la ubicación de transferencia' });
		}
	},

	async getEquipmentOperationalLocations(req: Request, res: Response) {
		const { equipmentId } = req.params;
		try {
			const operationalLocations = await db
				.select()
				.from(EquipmentOperationalLocation)
				.where(eq(EquipmentOperationalLocation.equipmentUuid, equipmentId));

			const locations = operationalLocations.map(
				(loc) => loc.locationTechnicalCode
			);
			res.status(200).json(locations);
		} catch (error) {
			res.status(500).json({
				message: 'Error al obtener ubicaciones operacionales del equipo',
				details: error.message
			});
		}
	}
};
