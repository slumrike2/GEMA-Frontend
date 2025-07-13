import { Router } from 'express';
import { reportOriginController } from '../controllers/reportOrigin.controller';

const router = Router();

router.get('/', reportOriginController.getAll);
router.get('/:id', reportOriginController.getByPk);
router.post('/', reportOriginController.insert);
router.put('/:id', reportOriginController.update);
router.delete('/:id', reportOriginController.delete);

export default router;
