import { createCrud } from './crudFactory';
import { TechnicalLocationTypes } from '../db/schema/schema';
import { LocationTypeSchema } from '../db/schema/validationSchema';
import { db } from '../db';

const baseTechnicalLocationTypesController = createCrud({
	table: TechnicalLocationTypes,
	validationSchema: LocationTypeSchema,
	objectName: 'TechnicalLocationTypes'
});

export const technicalLocationTypesController = {
	...baseTechnicalLocationTypesController,	
}