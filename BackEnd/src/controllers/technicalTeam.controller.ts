import { createCrud } from './crudFactory';
import { technicalTeam } from '../db/schema/schema';
import { technicalTeamSchema } from '../db/schema/validationSchema';
import { Request, Response } from 'express';
import { eq } from 'drizzle-orm';
import { db } from '../db';

const baseTechnicalTeamController = createCrud({
	table: technicalTeam,
	validationSchema: technicalTeamSchema,
	objectName: 'TechnicalTeam'
});

export const technicalTeamController = {
	...baseTechnicalTeamController,

	async getBySpeciality(req: Request, res: Response) {
		const speciality = req.params.speciality;
		try {
			const result = await db
				.select()
				.from(technicalTeam)
				.where(eq(technicalTeam.speciality, speciality as any));
			res.status(200).json(result);
		} catch (error) {
			res.status(500).json({ error: error.message });
		}
	},

	async getByLeader(req: Request, res: Response) {
		const leaderId = req.params.leaderId;
		try {
			const result = await db
				.select()
				.from(technicalTeam)
				.where(eq(technicalTeam.leaderId, leaderId));
		} catch (error) {
			res.status(500).json({ error: error.message });
		}
	}
};
