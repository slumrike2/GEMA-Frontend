import { db } from '../db';
import { Request, Response } from 'express';

function getEnumHandler(enumName: string) {
	return async (_req: Request, res: Response) => {
		const result = await db.execute(
			`SELECT unnest(enum_range(NULL::"${enumName}")) as value`
		);
		res.json(Array.isArray(result) ? result.map((r: any) => r.value) : []);
	};
}

export const getRoles = getEnumHandler('roles');
export const getEquipmentStates = getEnumHandler('equipment_state');
export const getReportOriginSources = getEnumHandler('Report_Origin_Source');
export const getReportPriorities = getEnumHandler('report_priority');
export const getReportTypes = getEnumHandler('report_type');
export const getReportStates = getEnumHandler('report_state');
