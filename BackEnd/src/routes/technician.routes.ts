import { Router } from 'express';
import { technicianController } from '../controllers/technician.controller';

const router = Router();

// View endpoint: user + technician info
router.get('/view', technicianController.getTechnicianUserView);

// Unassigned technicians endpoint and assign team
router.get('/unassigned', technicianController.getUnassignedTechnicians);
router.patch('/:uuid/technical-team', technicianController.assignTechnicalTeam);

router.get('/', technicianController.getAll);
router.get('/:uuid', technicianController.getByPk);
router.post('/', technicianController.insert);
router.put('/:uuid', technicianController.update);
router.delete('/:uuid', technicianController.delete);
router.get(
	'/technical-team/:technicalTeamId',
	technicianController.getByTechnicalTeam
);

export default router;
