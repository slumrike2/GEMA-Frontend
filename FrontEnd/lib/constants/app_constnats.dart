import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';

class AppConstants {
  static const String noneSelectedValue = "__NONE__";

  static const Map<EquipmentState, Color> equipmentStateColors = {
    EquipmentState.instalado: Colors.green,
    EquipmentState.en_mantenimiento: Colors.red,
    EquipmentState.mantenimiento_pendiente: Colors.orange,
    EquipmentState.en_reparaciones: Colors.red,
    EquipmentState.reparaciones_pendientes: Colors.orange,
    EquipmentState.en_inventario: Colors.grey,
    EquipmentState.descomisionado: Colors.black54,
    EquipmentState.transferencia_pendiente: Colors.blue,
  };

  static const Map<ReportPriority, Color> reportPriorityColors = {
    ReportPriority.high: Colors.red,
    ReportPriority.medium: Colors.orange,
    ReportPriority.low: Colors.green,
  };

  static const Map<ReportState, Color> reportStateColors = {
    ReportState.pending: Colors.grey,
    ReportState.programmed: Colors.blue,
    ReportState.inProgress: Colors.orange,
    ReportState.solved: Colors.green,
    ReportState.cancelled: Colors.red,
  };

  static const Map<String, IconData> locationTypeIcons = {
    "sede": Icons.business,
    "edificio": Icons.apartment,
    "piso": Icons.layers,
    "salon": Icons.room,
    "laboratorio": Icons.science,
    "oficina": Icons.local_post_office,
    "default": Icons.location_on,
  };

  static const Map<UserRole, Color> userRoleColors = {
    UserRole.user: Colors.blue,
    UserRole.technician: Colors.green,
    UserRole.coordinator: Colors.orange,
    UserRole.admin: Colors.red,
  };
}

class AppColors {
  static const Color primary = Color(0xFF166534);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF111827);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
}

enum LocationTypeEnum {
  business,
  apartment,
  layers,
  room,
  science,
  localPostOffice,
  localCafe,
  menuBook,
  fitnessCenter,
  theaterComedy,
  localParking,
  park,
  handyman,
  warehouse,
  doorFrontDoor,
  meetingRoom,
  weekend,
  computer,
  biotech,
  eco,
  locationOn,
}

const Map<LocationTypeEnum, IconData> locationTypeIcons = {
  LocationTypeEnum.business: Icons.business,
  LocationTypeEnum.apartment: Icons.apartment,
  LocationTypeEnum.layers: Icons.layers,
  LocationTypeEnum.room: Icons.room,
  LocationTypeEnum.science: Icons.science,
  LocationTypeEnum.localPostOffice: Icons.local_post_office,
  LocationTypeEnum.localCafe: Icons.local_cafe,
  LocationTypeEnum.menuBook: Icons.menu_book,
  LocationTypeEnum.fitnessCenter: Icons.fitness_center,
  LocationTypeEnum.theaterComedy: Icons.theater_comedy,
  LocationTypeEnum.localParking: Icons.local_parking,
  LocationTypeEnum.park: Icons.park,
  LocationTypeEnum.handyman: Icons.handyman,
  LocationTypeEnum.warehouse: Icons.warehouse,
  LocationTypeEnum.doorFrontDoor: Icons.door_front_door,
  LocationTypeEnum.meetingRoom: Icons.meeting_room,
  LocationTypeEnum.weekend: Icons.weekend,
  LocationTypeEnum.computer: Icons.computer,
  LocationTypeEnum.biotech: Icons.biotech,
  LocationTypeEnum.eco: Icons.eco,
  LocationTypeEnum.locationOn: Icons.location_on,
};
