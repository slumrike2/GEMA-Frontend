// @ts-nocheck

import { reportController } from '../src/controllers/report.controller';
import { db } from '../src/db';
import {
	Report,
	ReportEquipment,
	ReportTechnicalLocation
} from '../src/db/schema/schema';

jest.mock('../src/db', () => ({
	db: {
		select: jest.fn().mockReturnThis(),
		from: jest.fn().mockReturnThis(),
		where: jest.fn().mockReturnThis(),
		insert: jest.fn().mockReturnThis(),
		values: jest.fn().mockReturnThis(),
		returning: jest.fn().mockReturnThis()
	}
}));

describe('reportController', () => {
	let req, res;
	beforeEach(() => {
		req = { params: {}, body: {} };
		res = {
			status: jest.fn().mockReturnThis(),
			json: jest.fn()
		};
		jest.clearAllMocks();
	});

	describe('getByLocation', () => {
		it('should handle missing technicalCode param', async () => {
			req.params = {};
			db.where.mockReturnValueOnce([]);
			await reportController.getByLocation(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith([]);
		});

		it('should handle large number of report links', async () => {
			req.params.technicalCode = 'LOC_BIG';
			const reportLinks = Array.from({ length: 1000 }, (_, i) => ({
				reportId: i + 1
			}));
			const reports = Array.from({ length: 1000 }, (_, i) => ({ id: i + 1 }));
			db.select.mockReturnThis();
			db.from.mockReturnThis();
			db.where.mockReturnValueOnce(reportLinks).mockReturnValueOnce(reports);
			await reportController.getByLocation(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith(reports);
		});
		it('should return reports for a location', async () => {
			req.params.technicalCode = 'LOC1';
			const reportLinks = [{ reportId: 1 }, { reportId: 2 }];
			const reports = [{ id: 1 }, { id: 2 }];
			db.select.mockReturnThis();
			db.from.mockReturnThis();
			db.where
				.mockReturnValueOnce(reportLinks) // for ReportTechnicalLocation
				.mockReturnValueOnce(reports); // for Report
			await reportController.getByLocation(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith(reports);
		});

		it('should return empty array if no reports found', async () => {
			req.params.technicalCode = 'LOC2';
			db.where.mockReturnValueOnce([]); // no links
			await reportController.getByLocation(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith([]);
		});

		it('should handle errors', async () => {
			req.params.technicalCode = 'ERR';
			db.where.mockImplementationOnce(() => {
				throw new Error('fail');
			});
			await reportController.getByLocation(req, res);
			expect(res.status).toHaveBeenCalledWith(500);
			expect(res.json).toHaveBeenCalledWith(
				expect.objectContaining({ error: expect.any(String) })
			);
		});
	});

	describe('getByEquipment', () => {
		it('should handle missing equipmentUuid param', async () => {
			req.params = {};
			db.where.mockReturnValueOnce([]);
			await reportController.getByEquipment(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith([]);
		});

		it('should handle large number of report links', async () => {
			req.params.equipmentUuid = 'EQ_BIG';
			const reportLinks = Array.from({ length: 500 }, (_, i) => ({
				reportId: i + 1
			}));
			const reports = Array.from({ length: 500 }, (_, i) => ({ id: i + 1 }));
			db.where.mockReturnValueOnce(reportLinks).mockReturnValueOnce(reports);
			await reportController.getByEquipment(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith(reports);
		});
		it('should return reports for equipment', async () => {
			req.params.equipmentUuid = 'EQ1';
			const reportLinks = [{ reportId: 3 }];
			const reports = [{ id: 3 }];
			db.where.mockReturnValueOnce(reportLinks).mockReturnValueOnce(reports);
			await reportController.getByEquipment(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith(reports);
		});

		it('should return empty array if no reports found', async () => {
			req.params.equipmentUuid = 'EQ2';
			db.where.mockReturnValueOnce([]);
			await reportController.getByEquipment(req, res);
			expect(res.status).toHaveBeenCalledWith(200);
			expect(res.json).toHaveBeenCalledWith([]);
		});

		it('should handle errors', async () => {
			req.params.equipmentUuid = 'ERR';
			db.where.mockImplementationOnce(() => {
				throw new Error('fail');
			});
			await reportController.getByEquipment(req, res);
			expect(res.status).toHaveBeenCalledWith(500);
			expect(res.json).toHaveBeenCalledWith(
				expect.objectContaining({ error: expect.any(String) })
			);
		});
	});

	describe('associateEquipments', () => {
		it('should handle empty equipmentUuids array', async () => {
			req.params.reportId = '1';
			req.body.equipmentUuids = [];
			const result = [];
			db.returning.mockReturnValueOnce(result);
			await reportController.associateEquipments(req, res);
			expect(res.status).toHaveBeenCalledWith(201);
			expect(res.json).toHaveBeenCalledWith(result);
		});

		it('should handle duplicate equipmentUuids', async () => {
			req.params.reportId = '1';
			const uuid = '123e4567-e89b-12d3-a456-426614174000';
			req.body.equipmentUuids = [uuid, uuid];
			const result = [{ id: 1 }, { id: 2 }];
			db.returning.mockReturnValueOnce(result);
			await reportController.associateEquipments(req, res);
			expect(res.status).toHaveBeenCalledWith(201);
			expect(res.json).toHaveBeenCalledWith(result);
		});

		it('should handle invalid UUID in equipmentUuids', async () => {
			req.params.reportId = '1';
			req.body.equipmentUuids = ['not-a-uuid'];
			await reportController.associateEquipments(req, res);
			expect(res.status).toHaveBeenCalledWith(400);
			expect(res.json).toHaveBeenCalledWith(
				expect.objectContaining({ error: expect.any(String) })
			);
		});
		it('should associate equipments and return result', async () => {
			req.params.reportId = '1';
			req.body.equipmentUuids = [
				'123e4567-e89b-12d3-a456-426614174000',
				'123e4567-e89b-12d3-a456-426614174001'
			];
			const result = [{ id: 1 }, { id: 2 }];
			db.returning.mockReturnValueOnce(result);
			await reportController.associateEquipments(req, res);
			expect(res.status).toHaveBeenCalledWith(201);
			expect(res.json).toHaveBeenCalledWith(result);
		});

		it('should handle validation error', async () => {
			req.params.reportId = '1';
			req.body.equipmentUuids = 'not-an-array';
			await reportController.associateEquipments(req, res);
			expect(res.status).toHaveBeenCalledWith(400);
			expect(res.json).toHaveBeenCalledWith(
				expect.objectContaining({ error: expect.any(String) })
			);
		});
	});

	describe('associateLocations', () => {
		it('should handle empty technicalCodes array', async () => {
			req.params.reportId = '2';
			req.body.technicalCodes = [];
			const result = [];
			db.returning.mockReturnValueOnce(result);
			await reportController.associateLocations(req, res);
			expect(res.status).toHaveBeenCalledWith(201);
			expect(res.json).toHaveBeenCalledWith(result);
		});

		it('should handle duplicate technicalCodes', async () => {
			req.params.reportId = '2';
			req.body.technicalCodes = ['T1', 'T1'];
			const result = [{ id: 1 }, { id: 2 }];
			db.returning.mockReturnValueOnce(result);
			await reportController.associateLocations(req, res);
			expect(res.status).toHaveBeenCalledWith(201);
			expect(res.json).toHaveBeenCalledWith(result);
		});
		it('should associate locations and return result', async () => {
			req.params.reportId = '2';
			req.body.technicalCodes = ['T1', 'T2'];
			const result = [{ id: 1 }, { id: 2 }];
			db.returning.mockReturnValueOnce(result);
			await reportController.associateLocations(req, res);
			expect(res.status).toHaveBeenCalledWith(201);
			expect(res.json).toHaveBeenCalledWith(result);
		});

		it('should handle validation error', async () => {
			req.params.reportId = '2';
			req.body.technicalCodes = 'not-an-array';
			await reportController.associateLocations(req, res);
			expect(res.status).toHaveBeenCalledWith(400);
			expect(res.json).toHaveBeenCalledWith(
				expect.objectContaining({ error: expect.any(String) })
			);
		});
	});
});
