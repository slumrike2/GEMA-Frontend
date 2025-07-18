import { reportOrigin } from '../db/schema/schema';
import { reportOriginSchema } from '../db/schema/validationSchema';
import { createCrud } from './crudFactory';

export const reportOriginController = createCrud({
	table: reportOrigin,
	validationSchema: reportOriginSchema,
	objectName: 'ReportOrigin'
});
