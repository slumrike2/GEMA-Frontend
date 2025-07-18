import { brand } from '../../supabase/migrations/schema';
import { brandSchema } from '../db/schema/validationSchema';
import { createCrud } from './crudFactory';

export const brandController = createCrud({
	table: brand,
	validationSchema: brandSchema,
	objectName: 'Brand'
});
