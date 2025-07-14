import { Router } from 'express';
import { reportUpdateController } from '../controllers/reportUpdate.controller';

const router = Router();

router.get('/', reportUpdateController.getAll);
router.get('/:id', reportUpdateController.getByPk);
router.post('/', reportUpdateController.insert);
router.put('/:id', reportUpdateController.update);
router.delete('/:id', reportUpdateController.delete);

export default router;
