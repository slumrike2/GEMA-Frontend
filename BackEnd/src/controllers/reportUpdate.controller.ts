import { createCrud } from './crudFactory';
import { ReportUpdate } from '../db/schema/schema';
import { ReportUpdateSchema } from '../db/schema/validationSchema';

export const reportUpdateController = createCrud({
	table: ReportUpdate,
	validationSchema: ReportUpdateSchema,
	objectName: 'ReportUpdate'
});
