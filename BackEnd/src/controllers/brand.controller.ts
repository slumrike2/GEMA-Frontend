import { createCrud } from './crudFactory';
import { Brand } from '../db/schema/schema';
import { BrandSchema } from '../db/schema/validationSchema';

export const brandController = createCrud({
	table: Brand,
	validationSchema: BrandSchema,
	objectName: 'Brand'
});
