import { relations } from "drizzle-orm/relations";
import { equipment, equipmentOperationalLocation, brand, technicalLocation, user, reportOrigin, technicalTeam, technician, technicalLocationTypes } from "./schema";

export const equipmentOperationalLocationRelations = relations(equipmentOperationalLocation, ({one}) => ({
	equipment: one(equipment, {
		fields: [equipmentOperationalLocation.equipmentUuid],
		references: [equipment.uuid]
	}),
}));

export const equipmentRelations = relations(equipment, ({one, many}) => ({
	equipmentOperationalLocations: many(equipmentOperationalLocation),
	brand: one(brand, {
		fields: [equipment.brandId],
		references: [brand.id]
	}),
	equipment_dependsOn: one(equipment, {
		fields: [equipment.dependsOn],
		references: [equipment.uuid],
		relationName: "equipment_dependsOn_equipment_uuid"
	}),

	technicalLocation_technicalLocation: one(technicalLocation, {
		fields: [equipment.technicalLocation],
		references: [technicalLocation.technicalCode],
		relationName: "equipment_technicalLocation_technicalLocation_technicalCode"
	}),
	technicalLocation_transferLocation: one(technicalLocation, {
		fields: [equipment.transferLocation],
		references: [technicalLocation.technicalCode],
		relationName: "equipment_transferLocation_technicalLocation_technicalCode"
	}),
}));

export const brandRelations = relations(brand, ({many}) => ({
	equipment: many(equipment),
}));

export const technicalLocationRelations = relations(technicalLocation, ({one, many}) => ({
	equipment_technicalLocation: many(equipment, {
		relationName: "equipment_technicalLocation_technicalLocation_technicalCode"
	}),
	equipment_transferLocation: many(equipment, {
		relationName: "equipment_transferLocation_technicalLocation_technicalCode"
	}),
	technicalLocationType: one(technicalLocationTypes, {
		fields: [technicalLocation.type],
		references: [technicalLocationTypes.id]
	}),
}));

export const reportOriginRelations = relations(reportOrigin, ({one}) => ({
	user: one(user, {
		fields: [reportOrigin.gemAcreator],
		references: [user.uuid]
	}),
}));

export const userRelations = relations(user, ({many}) => ({
	reportOrigins: many(reportOrigin),
	technicians: many(technician),
}));

export const technicianRelations = relations(technician, ({one, many}) => ({
	technicalTeam: one(technicalTeam, {
		fields: [technician.technicalTeamId],
		references: [technicalTeam.id],
		relationName: "technician_technicalTeamId_technicalTeam_id"
	}),
	user: one(user, {
		fields: [technician.uuid],
		references: [user.uuid]
	}),
	technicalTeams: many(technicalTeam, {
		relationName: "technicalTeam_leaderId_technician_uuid"
	}),
}));

export const technicalTeamRelations = relations(technicalTeam, ({one, many}) => ({
	technicians: many(technician, {
		relationName: "technician_technicalTeamId_technicalTeam_id"
	}),
	technician: one(technician, {
		fields: [technicalTeam.leaderId],
		references: [technician.uuid],
		relationName: "technicalTeam_leaderId_technician_uuid"
	}),
}));

export const technicalLocationTypesRelations = relations(technicalLocationTypes, ({many}) => ({
	technicalLocations: many(technicalLocation),
}));