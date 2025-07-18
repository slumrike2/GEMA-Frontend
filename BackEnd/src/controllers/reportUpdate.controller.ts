import { reportUpdate } from '../db/schema/schema';
import { reportUpdateSchema } from '../db/schema/validationSchema';
import { createCrud } from './crudFactory';

export const reportUpdateController = createCrud({
	table: reportUpdate,
	validationSchema: reportUpdateSchema,
	objectName: 'ReportUpdate'
});
