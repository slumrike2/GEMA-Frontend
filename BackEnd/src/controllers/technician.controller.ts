import { createCrud } from './crudFactory';
import { Technician, User } from '../db/schema/schema';
import { TechnicianSchema } from '../db/schema/validationSchema';
import { db } from '../db';
import { Request, Response } from 'express';
import { eq } from 'drizzle-orm';

const baseTechnicianController = createCrud({
  table: Technician,
  validationSchema: TechnicianSchema,
  objectName: 'Technician',
});

export const technicianController = {
  ...baseTechnicianController,

  async getByTechnicalTeam(req: Request, res: Response) {
    const technicalTeamId = req.params.technicalTeamId;
    try {
      const result = await db
        .select()
        .from(Technician)
        .where(eq(Technician.technicalTeamId, parseInt(technicalTeamId)));
      res.status(200).json(result);
    } catch (error) {
      console.error('[Technician] getByTechnicalTeam error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  },

  async insertFromUser(req: Request, res: Response) {
    const { uuid, speciality, technicalTeamId, contact } = req.body;

    if (!uuid) {
      return res.status(400).json({ error: 'El campo uuid es obligatorio.' });
    }

    try {
      const user = await db.select().from(User).where(eq(User.uuid, uuid)).limit(1);
      if (!user || user.length === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado.' });
      }

      const technicianData = {
        uuid,
        personalId: user[0].name || '',
        contact: contact || '',
        speciality,
        technicalTeamId: technicalTeamId ? Number(technicalTeamId) : null,
      };

      await TechnicianSchema.parseAsync(technicianData);

      const inserted = await db.insert(Technician).values(technicianData).returning();

      res.status(201).json(inserted[0]);
    } catch (error: any) {
      console.error('[Technician] insertFromUser error:', error);
      res.status(500).json({ error: 'Error al crear técnico', details: error.message || error.toString() });
    }
  },
};
