import { Router } from 'express';
import { brandController } from '../controllers/brand.controller';

const router = Router();

router.get('/', brandController.getAll);
router.get('/:id', brandController.getByPk);
router.post('/', brandController.insert);
router.put('/:id', brandController.update);
router.delete('/:id', brandController.delete);

export default router;
