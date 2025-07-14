import { Router } from 'express';
import { technicalTeamController } from '../controllers/technicalTeam.controller';

const router = Router();

router.get('/', technicalTeamController.getAll);
router.get('/:id', technicalTeamController.getByPk);
router.post('/', technicalTeamController.insert);
router.put('/:id', technicalTeamController.update);
router.delete('/:id', technicalTeamController.delete);
router.get('speciality/:speciality', technicalTeamController.getBySpeciality);
router.get('leader/:leaderId', technicalTeamController.getByLeader);


export default router;
