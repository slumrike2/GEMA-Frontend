import { createCrud } from './crudFactory';
import { User, Technician } from '../db/schema/schema';
import { UserSchema } from '../db/schema/validationSchema';
import { Request, Response, NextFunction } from 'express';
import { db } from '../db';
import { sendWelcomeEmail } from '../utils/mailer';
import { eq, not, exists } from 'drizzle-orm';

// Helper para manejar async errors en Express
const asyncHandler = (fn: Function) => (req: Request, res: Response, next: NextFunction) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

const baseUserController = createCrud({
  table: User,
  validationSchema: UserSchema,
  objectName: 'User',
});

export const userController = {
  ...baseUserController,

  getAvailableUsers: asyncHandler(async (req: Request, res: Response) => {
    const availableUsers = await db
      .select()
      .from(User)
      .where(
        not(
          exists(
            db.select()
              .from(Technician)
              .where(eq(Technician.uuid, User.uuid))
          )
        )
      );
    res.status(200).json(availableUsers);
  }),

  createWithEmail: asyncHandler(async (req: Request, res: Response) => {
    const { uuid, email, role, password } = req.body;

    const result = await db
      .insert(User)
      .values({ uuid, email, role })
      .returning();

    await sendWelcomeEmail(email, password);

    res.status(201).json(result[0]);
  }),

  updateName: asyncHandler(async (req: Request, res: Response) => {
    const { uuid } = req.params;
    const { name } = req.body;

    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return res.status(400).json({ error: 'El campo name debe ser un string no vacío.' });
    }

    const result = await db
      .update(User)
      .set({ name })
      .where(eq(User.uuid, uuid))
      .returning();

    if (!result[0]) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    res.status(200).json(result[0]);
  }),
};
