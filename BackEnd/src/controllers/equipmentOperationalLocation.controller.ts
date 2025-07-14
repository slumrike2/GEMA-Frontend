import { createCrud } from './crudFactory';
import { EquipmentOperationalLocation } from '../db/schema/schema';
import { EquipmentOperationalLocationSchema } from '../db/schema/validationSchema';

export const equipmentOperationalLocationController = createCrud({
	table: EquipmentOperationalLocation,
	validationSchema: EquipmentOperationalLocationSchema,
	objectName: 'EquipmentOperationalLocation'
});
