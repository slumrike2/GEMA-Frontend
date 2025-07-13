import { Router } from 'express';
import { technicalLocationTypesController } from '../controllers/technicalLocationTypes.controller';

const router = Router();

router.get('/', technicalLocationTypesController.getAll);
router.get('/:id', technicalLocationTypesController.getByPk);
router.post('/', technicalLocationTypesController.insert);
router.put('/:id', technicalLocationTypesController.update);
router.delete('/:id', technicalLocationTypesController.delete);

export default router;
