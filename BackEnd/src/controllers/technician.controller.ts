import { createCrud } from './crudFactory';
import { technician } from '../db/schema/schema';
import { technicianSchema } from '../db/schema/validationSchema';
import { db } from '../db';
import { Request, Response } from 'express';
import { z } from 'zod';
import { and, eq, inArray, isNull, not } from 'drizzle-orm';

const baseTechnicianController = createCrud({
	table: technician,
	validationSchema: technicianSchema,
	objectName: 'Technician'
});

export const technicianController = {
	...baseTechnicianController,

	// GET /api/technicians/view
	async getTechnicianUserView(req: Request, res: Response) {
		try {
			// Import user and join with technician
			const { user } = await import('../db/schema/schema');
			const result = await db
				.select({
					userId: user.uuid,
					userName: user.name,
					userEmail: user.email,
					personalId: technician.personalId,
					contact: technician.contact,
					speciality: technician.speciality,
					technicalTeamId: technician.technicalTeamId
				})
				.from(technician)
				.innerJoin(user, eq(user.uuid, technician.uuid));

			res.status(200).json(result);
		} catch (error) {
			console.error('Error getting technician user view:', error);
			res.status(500).json({ error: 'Internal server error' });
		}
	},

	async getByTechnicalTeam(req: Request, res: Response) {
		const technicalTeamId = req.params.technicalTeamId;
		try {
			const result = await db
				.select()
				.from(technician)
				.where(eq(technician.technicalTeamId, parseInt(technicalTeamId)));

			res.status(200).json(result);
		} catch (error) {
			console.error('Error getting technicians by technical team:', error);
			res.status(500).json({ error: 'Internal server error' });
		}
	},

	// GET /api/technicians/unassigned
	async getUnassignedTechnicians(req: Request, res: Response) {
		try {
			const { technicalTeam } = await import('../db/schema/schema');
			const leaderRows = await db.select({ leaderId: technicalTeam.leaderId }).from(technicalTeam);
			const leaderUuids = Array.from(
				new Set(
					leaderRows
						.map(r => r.leaderId)
						.filter((id): id is string => Boolean(id))
				)
			);

			const baseCondition = isNull(technician.technicalTeamId);
			const whereCondition =
				leaderUuids.length > 0
					? and(baseCondition, not(inArray(technician.uuid, leaderUuids)))
					: baseCondition;

			const result = await db.select().from(technician).where(whereCondition);
			res.status(200).json(result);
		} catch (error) {
			console.error('Error getting unassigned technicians:', error);
			res.status(500).json({ error: 'Internal server error' });
		}
	},

	// PATCH /api/technicians/:uuid/technical-team
	async assignTechnicalTeam(req: Request, res: Response) {
		try {
			const { uuid } = req.params;
			const bodySchema = z.object({
				technicalTeamId: z.number().nullable(),
			});
			const { technicalTeamId } = bodySchema.parse(req.body);

			const result = await db
				.update(technician)
				.set({ technicalTeamId })
				.where(eq(technician.uuid, uuid))
				.returning();

			res.status(200).json(result[0] || null);
		} catch (error) {
			if (error instanceof z.ZodError) {
				res.status(400).json({ error: 'Validation Error', details: error.errors });
				return;
			}
			console.error('Error assigning technical team:', error);
			res.status(500).json({ error: 'Internal server error' });
		}
	}
};
