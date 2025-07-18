import { createCrud } from './crudFactory';
import { technicalLocationTypes } from '../db/schema/schema';
import { db } from '../db';
import { technicalLocationTypesSchema } from '../db/schema/validationSchema';

const baseTechnicalLocationTypesController = createCrud({
	table: technicalLocationTypes,
	validationSchema: technicalLocationTypesSchema,
	objectName: 'TechnicalLocationTypes'
});

export const technicalLocationTypesController = {
	...baseTechnicalLocationTypesController,	
}