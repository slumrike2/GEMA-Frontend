import { createCrud } from './crudFactory';
import { ReportOrigin } from '../db/schema/schema';
import { ReportOriginSchema } from '../db/schema/validationSchema';

export const reportOriginController = createCrud({
	table: ReportOrigin,
	validationSchema: ReportOriginSchema,
	objectName: 'ReportOrigin'
});
