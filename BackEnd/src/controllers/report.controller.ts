import { createCrud } from './crudFactory';
import { ReportSchema } from '../db/schema/validationSchema';
import { db } from '../db';
import {
	ReportEquipment,
	ReportTechnicalLocation,
	Report
} from '../db/schema/schema';
import { z } from 'zod';
import { eq, inArray } from 'drizzle-orm';

export const baseReportController = createCrud({
	table: Report,
	validationSchema: ReportSchema,
	objectName: 'Report'
});

export const reportController = {
	...baseReportController,

	/**
	 * Obtiene los reportes asociados a una ubicación técnica
	 *
	 * Endpoint: GET /api/report/by-location/:technicalCode
	 *
	 * Recibe en los params:
	 * - technicalCode: Código técnico de la ubicación
	 *
	 * Devuelve un array de reportes asociados a esa ubicación.
	 * Responde 200 si es exitoso, 500 si hay error.
	 */
	async getByLocation(req, res) {
		const { technicalCode } = req.params;
		try {
			const reportLinks = await db
				.select()
				.from(ReportTechnicalLocation)
				.where(eq(ReportTechnicalLocation.technicalCode, technicalCode));
			const reportIds = reportLinks.map((link) => link.reportId);
			let reports = [];
			if (reportIds.length) {
				reports = await db
					.select()
					.from(Report)
					.where(inArray(Report.id, reportIds));
			}
			res.status(200).json(reports);
		} catch (error) {
			res.status(500).json({
				error: 'Error fetching reports by location',
				details: error.message
			});
		}
	},

	/**
	 * Obtiene los reportes asociados a un equipo
	 *
	 * Endpoint: GET /api/report/by-equipment/:equipmentUuid
	 *
	 * Recibe en los params:
	 * - equipmentUuid: UUID del equipo
	 *
	 * Devuelve un array de reportes asociados a ese equipo.
	 * Responde 200 si es exitoso, 500 si hay error.
	 */
	async getByEquipment(req, res) {
		const { equipmentUuid } = req.params;
		try {
			const reportLinks = await db
				.select()
				.from(ReportEquipment)
				.where(eq(ReportEquipment.equipmentUuid, equipmentUuid));
			const reportIds = reportLinks.map((link) => link.reportId);
			let reports = [];
			if (reportIds.length) {
				reports = await db
					.select()
					.from(Report)
					.where(inArray(Report.id, reportIds));
			}
			res.status(200).json(reports);
		} catch (error) {
			res.status(500).json({
				error: 'Error fetching reports by equipment',
				details: error.message
			});
		}
	},

	/**
	 * Asocia uno o varios equipos a un reporte (relación muchos-a-muchos)
	 *
	 * Endpoint: POST /api/report/associate-equipments/:reportId
	 *
	 * Recibe en los params:
	 * - reportId: ID del reporte
	 *
	 * Recibe en el body:
	 * - equipmentUuids: array de UUIDs de equipos a asociar
	 *
	 * Inserta nuevas relaciones en la tabla ReportEquipment.
	 * Responde 201 si la asociación es exitosa, 400 si hay error de validación.
	 */
	async associateEquipments(req, res) {
		const { reportId } = req.params;
		const schema = z.object({ equipmentUuids: z.array(z.string().uuid()) });
		try {
			const { equipmentUuids } = schema.parse(req.body);
			const values = equipmentUuids.map((equipmentUuid) => ({
				reportId: Number(reportId),
				equipmentUuid
			}));
			const result = await db
				.insert(ReportEquipment)
				.values(values)
				.returning();
			res.status(201).json(result);
		} catch (error) {
			res.status(400).json({
				error: 'Error associating equipments',
				details: error.message
			});
		}
	},

	/**
	 * Asocia una o varias ubicaciones técnicas a un reporte (relación muchos-a-muchos)
	 *
	 * Endpoint: POST /api/report/associate-locations/:reportId
	 *
	 * Recibe en los params:
	 * - reportId: ID del reporte
	 *
	 * Recibe en el body:
	 * - technicalCodes: array de códigos técnicos de ubicaciones a asociar
	 *
	 * Inserta nuevas relaciones en la tabla ReportTechnicalLocation.
	 * Responde 201 si la asociación es exitosa, 400 si hay error de validación.
	 */
	async associateLocations(req, res) {
		const { reportId } = req.params;
		const schema = z.object({ technicalCodes: z.array(z.string()) });
		try {
			const { technicalCodes } = schema.parse(req.body);
			const values = technicalCodes.map((technicalCode) => ({
				reportId: Number(reportId),
				technicalCode
			}));
			const result = await db
				.insert(ReportTechnicalLocation)
				.values(values)
				.returning();
			res.status(201).json(result);
		} catch (error) {
			res
				.status(400)
				.json({ error: 'Error associating locations', details: error.message });
		}
	}
};
