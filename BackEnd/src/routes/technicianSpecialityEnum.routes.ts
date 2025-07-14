import { Router } from 'express';
import { technicianSpecialityEnumController } from '../controllers/technicianSpecialityEnum.controller';

const router = Router();

router.get('/', technicianSpecialityEnumController.getAll);

export default router; 