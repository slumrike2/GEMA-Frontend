// Generated from backend schema.ts and validationSchema.ts
// Do not edit by hand. Update via backend schema changes.

// ignore_for_file: constant_identifier_names

import 'package:meta/meta.dart';

// Enums

enum UserRole { user, technician, coordinator, admin }

enum EquipmentState {
  instalado,
  en_mantenimiento,
  mantenimiento_pendiente,
  en_reparaciones,
  reparaciones_pendientes,
  en_inventario,
  descomisionado,
  transferencia_pendiente,
}

enum ReportOriginSource { email, managementSystem, chat, GEMA }

enum ReportPriority { high, medium, low }

enum ReportType { preventive, active }

enum ReportState { pending, programmed, inProgress, solved, cancelled }

// Models

class LocationType {
  final String name;
  final String? description;
  final String nameTemplate;
  final String codeTemplate;

  LocationType({
    required this.name,
    this.description,
    required this.nameTemplate,
    required this.codeTemplate,
  });

  factory LocationType.fromJson(Map<String, dynamic> json) => LocationType(
    name: json['name'],
    description: json['description'],
    nameTemplate: json['nameTemplate'],
    codeTemplate: json['codeTemplate'],
  );
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    'nameTemplate': nameTemplate,
    'codeTemplate': codeTemplate,
  };
}

class User {
  final String? uuid;
  final String name;
  final String email;
  final UserRole? role;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  User({
    this.uuid,
    required this.name,
    required this.email,
    this.role,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    uuid: json['uuid'],
    name: json['name'],
    email: json['email'],
    role: json['role'] != null ? UserRole.values.byName(json['role']) : null,
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (uuid != null) 'uuid': uuid,
    'name': name,
    'email': email,
    if (role != null) 'role': role!.name,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}

class TechnicianSpeciality {
  final String codeName;
  final String? description;

  TechnicianSpeciality({required this.codeName, this.description});

  factory TechnicianSpeciality.fromJson(Map<String, dynamic> json) =>
      TechnicianSpeciality(
        codeName: json['codeName'],
        description: json['description'],
      );
  Map<String, dynamic> toJson() => {
    'codeName': codeName,
    if (description != null) 'description': description,
  };
}

class Technician {
  final String? uuid;
  final String personalId;
  final String contact;
  final String speciality;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  Technician({
    this.uuid,
    required this.personalId,
    required this.contact,
    required this.speciality,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
    uuid: json['uuid'],
    personalId: json['personalId'],
    contact: json['contact'],
    speciality: json['speciality'],
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (uuid != null) 'uuid': uuid,
    'personalId': personalId,
    'contact': contact,
    'speciality': speciality,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}

class TechnicalTeam {
  final int? id;
  final String name;
  final String? speciality;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  TechnicalTeam({
    this.id,
    required this.name,
    this.speciality,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory TechnicalTeam.fromJson(Map<String, dynamic> json) => TechnicalTeam(
    id: json['id'],
    name: json['name'],
    speciality: json['speciality'],
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    if (speciality != null) 'speciality': speciality,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}

class TechnicalLocation {
  final String technicalCode;
  final String name;
  final int type;
  final String? parentTechnicalCode;

  TechnicalLocation({
    required this.technicalCode,
    required this.name,
    required this.type,
    required this.parentTechnicalCode,
  });

  factory TechnicalLocation.fromJson(Map<String, dynamic> json) =>
      TechnicalLocation(
        technicalCode: json['technicalCode'],
        name: json['name'],
        type: json['type'],
        parentTechnicalCode: json['parentTechnicalCode'],
      );
  Map<String, dynamic> toJson() => {
    'technicalCode': technicalCode,
    'name': name,
    'type': type,
    'parentTechnicalCode': parentTechnicalCode,
  };
}

class Brand {
  final int? id;
  final String name;

  Brand({this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) =>
      Brand(id: json['id'], name: json['name']);
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'name': name};
}

class Equipment {
  final String? uuid;
  final String technicalCode;
  final String name;
  final String serialNumber;
  final String? description;
  final EquipmentState? state;
  final String? dependsOn;
  final int brandId;
  final String? technicalLocation;
  final String? transferLocation;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  Equipment({
    this.uuid,
    required this.technicalCode,
    required this.name,
    required this.serialNumber,
    this.description,
    this.state,
    this.dependsOn,
    required this.brandId,
    this.technicalLocation,
    this.transferLocation,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
    uuid: json['uuid'],
    technicalCode: json['technicalCode'],
    name: json['name'],
    serialNumber: json['serialNumber'],
    description: json['description'],
    state:
        json['state'] != null
            ? EquipmentState.values.byName(json['state'])
            : null,
    dependsOn: json['dependsOn'],
    brandId: json['brandId'],
    technicalLocation: json['technicalLocation'],
    transferLocation: json['transferLocation'],
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (uuid != null) 'uuid': uuid,
    'technicalCode': technicalCode,
    'name': name,
    'serialNumber': serialNumber,
    if (description != null) 'description': description,
    if (state != null) 'state': state!.name,
    if (dependsOn != null) 'dependsOn': dependsOn,
    'brandId': brandId,
    if (technicalLocation != null) 'technicalLocation': technicalLocation,
    if (transferLocation != null) 'transferLocation': transferLocation,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}

class EquipmentOperationalLocation {
  final int? id;
  final String equipmentId;
  final String locationId;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  EquipmentOperationalLocation({
    this.id,
    required this.equipmentId,
    required this.locationId,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory EquipmentOperationalLocation.fromJson(
    Map<String, dynamic> json,
  ) => EquipmentOperationalLocation(
    id: json['id'],
    equipmentId: json['equipmentId'],
    locationId: json['locationId'],
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'equipmentId': equipmentId,
    'locationId': locationId,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}

class ReportOrigin {
  final int? id;
  final String? emailRemitent;
  final String? GEMAcreator;
  final ReportOriginSource source;
  final String? description;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  ReportOrigin({
    this.id,
    this.emailRemitent,
    this.GEMAcreator,
    required this.source,
    this.description,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory ReportOrigin.fromJson(Map<String, dynamic> json) => ReportOrigin(
    id: json['id'],
    emailRemitent: json['emailRemitent'],
    GEMAcreator: json['GEMAcreator'],
    source: ReportOriginSource.values.byName(json['source']),
    description: json['description'],
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (emailRemitent != null) 'emailRemitent': emailRemitent,
    if (GEMAcreator != null) 'GEMAcreator': GEMAcreator,
    'source': source.name,
    if (description != null) 'description': description,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}

class Report {
  final int? id;
  final String title;
  final String description;
  final ReportPriority? priority;
  final ReportState? state;
  final ReportType? type;
  final String? notes;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  Report({
    this.id,
    required this.title,
    required this.description,
    this.priority,
    this.state,
    this.type,
    this.notes,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    priority:
        json['priority'] != null
            ? ReportPriority.values.byName(json['priority'])
            : null,
    state:
        json['state'] != null ? ReportState.values.byName(json['state']) : null,
    type: json['type'] != null ? ReportType.values.byName(json['type']) : null,
    notes: json['notes'],
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    if (priority != null) 'priority': priority!.name,
    if (state != null) 'state': state!.name,
    if (type != null) 'type': type!.name,
    if (notes != null) 'notes': notes,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}

class ReportUpdate {
  final int? id;
  final String description;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  ReportUpdate({
    this.id,
    required this.description,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  factory ReportUpdate.fromJson(Map<String, dynamic> json) => ReportUpdate(
    id: json['id'],
    description: json['description'],
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'description': description,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };
}
