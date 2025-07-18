import { createCrud } from './crudFactory';
import { equipmentOperationalLocation } from '../db/schema/schema';
import { equipmentOperationalLocationSchema } from '../db/schema/validationSchema';

export const equipmentOperationalLocationController = createCrud({
	table: equipmentOperationalLocation,
	validationSchema: equipmentOperationalLocationSchema,
	objectName: 'EquipmentOperationalLocation'
});
