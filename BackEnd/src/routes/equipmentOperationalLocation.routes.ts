import { Router } from 'express';
import { equipmentOperationalLocationController } from '../controllers/equipmentOperationalLocation.controller';

const router = Router();

router.get('/', equipmentOperationalLocationController.getAll);
// Composite PK: equipmentUuid, locationTechnicalCode
router.get(
	'/:equipmentUuid/:locationTechnicalCode',
	equipmentOperationalLocationController.getByPk
);
router.post('/', equipmentOperationalLocationController.insert);
router.put(
	'/:equipmentUuid/:locationTechnicalCode',
	equipmentOperationalLocationController.update
);
router.delete(
	'/:equipmentUuid/:locationTechnicalCode',
	equipmentOperationalLocationController.delete
);

export default router;
