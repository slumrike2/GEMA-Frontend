import { Request, Response } from 'express';
import { technicianSpecialityEnum } from '../db/schema/validationSchema';

export const technicianSpecialityEnumController = {
  getAll: (req: Request, res: Response) => {
    res.json(technicianSpecialityEnum.options);
  }
}; 