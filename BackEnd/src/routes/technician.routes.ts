import { Router } from 'express';
import { technicianController } from '../controllers/technician.controller';

const router = Router();

router.get('/', technicianController.getAll.bind(technicianController));
router.get('/technical-team/:technicalTeamId', technicianController.getByTechnicalTeam.bind(technicianController));
router.get('/:uuid', technicianController.getByPk.bind(technicianController));
router.post('/', technicianController.insert.bind(technicianController));
router.put('/:uuid', technicianController.update.bind(technicianController));
router.delete('/:uuid', technicianController.delete.bind(technicianController));
router.post('/from-user', technicianController.insertFromUser.bind(technicianController));

export default router;
