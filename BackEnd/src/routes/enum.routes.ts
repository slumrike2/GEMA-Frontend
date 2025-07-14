import { Router } from 'express';
import {
	getRoles,
	getEquipmentStates,
	getReportOriginSources,
	getReportPriorities,
	getReportTypes,
	getReportStates
} from '../controllers/enum.controller';

const router = Router();

router.get('/roles', getRoles);
router.get('/equipment-states', getEquipmentStates);
router.get('/report-origin-sources', getReportOriginSources);
router.get('/report-priorities', getReportPriorities);
router.get('/report-types', getReportTypes);
router.get('/report-states', getReportStates);

export default router;
