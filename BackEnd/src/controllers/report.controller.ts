import { createCrud } from './crudFactory';
import { report } from '../db/schema/schema';
import { reportSchema } from '../db/schema/validationSchema';

export const reportController = createCrud({
	table: report,
	validationSchema: reportSchema,
	objectName: 'Report'
});
