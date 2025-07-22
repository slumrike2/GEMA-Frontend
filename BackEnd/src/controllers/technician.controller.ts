import { createCrud } from './crudFactory';
import { technician } from '../db/schema/schema';
import { technicianSchema } from '../db/schema/validationSchema';
import { db } from '../db';
import { Request, Response } from 'express';
import { eq } from 'drizzle-orm';

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
	}
};
