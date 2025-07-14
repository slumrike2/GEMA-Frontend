import { createCrud } from './crudFactory';
import { Technician } from '../db/schema/schema';
import { TechnicianSchema } from '../db/schema/validationSchema';
import { db } from '../db';
import { Request, Response } from 'express';
import { eq } from 'drizzle-orm';

const baseTechnicianController = createCrud({
	table: Technician,
	validationSchema: TechnicianSchema,
	objectName: 'Technician'
});

export const technicianController = {
	...baseTechnicianController,

	async getByTechnicalTeam(req: Request, res: Response) {
		const technicalTeamId = req.params.technicalTeamId;
		try {
			const result = await db.select()
				.from(Technician)
				.where(eq(Technician.technicalTeamId, parseInt(technicalTeamId)));
			
			res.status(200).json(result);
		} catch (error) {
			console.error('Error getting technicians by technical team:', error);
			res.status(500).json({ error: 'Internal server error' });
		}
	}
}
