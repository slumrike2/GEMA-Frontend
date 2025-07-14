import { createCrud } from './crudFactory';
import { Report } from '../db/schema/schema';
import { ReportSchema } from '../db/schema/validationSchema';

export const reportController = createCrud({
	table: Report,
	validationSchema: ReportSchema,
	objectName: 'Report'
});
