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

class AppTextStyles {
  // Titles
  static TextStyle title({Color? color}) => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.primary,
  );

  static TextStyle subtitle({Color? color}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.primary,
  );

  static TextStyle sectionTitle({Color? color}) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.primary,
  );

  // Body
  static TextStyle body({Color? color}) =>
      TextStyle(fontSize: 18, color: color ?? AppColors.onSurface);

  static TextStyle bodySmall({Color? color}) =>
      TextStyle(fontSize: 16, color: color ?? AppColors.onSurfaceVariant);

  // Button
  static TextStyle button({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.white,
  );

  // Label
  static TextStyle label({Color? color}) =>
      TextStyle(fontSize: 13, color: color ?? AppColors.onSurfaceVariant);

  // Caption
  static TextStyle caption({Color? color}) =>
      TextStyle(fontSize: 11, color: color ?? AppColors.onSurfaceVariant);
}

class AppColors {
  /// Colores personalizados para la aplicación (migrados de constants.dart)
  static const Color primaryBlue = Color(0xFF0A3444); // Verde principal
  static const Color primaryGreen = Color(0xFF002811); // Azul claro
  static const Color primaryYellow = Color(0xFF2C2001); // Amarillo
  static const Color primaryGray = Color.fromARGB(255, 61, 61, 61); // Gris

  // Colores Fondos
  static const Color secondaryYellow = Color(0xFFFFF6E0);
  static const Color secondaryGreen = Color(0xFFC6E1D2);
  static const Color secondaryBlue = Color(0xFFD4EFF9);

  //Colores medianos
  static const Color mediumYellow = Color(0xFFFFE0B2);
  static const Color mediumGreen = Color(0xFFB2DFDB);
  static const Color mediumBlue = Color(0xFFB3E5FC);

  // colores de acento
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);

  //Colores de Iconos
  static const Color iconYellow = Color(0xFFFFA000);
  static const Color iconGreen = Color(0xFF388E3C);
  static const Color iconBlue = Color(0xFF1976D2);

  // Colores para botones
  static const Color botonBlue = Color.fromARGB(255, 5, 85, 117);
  static const Color botonGreen = Color.fromARGB(255, 1, 107, 47);
  static const Color botonYellow = Color.fromARGB(255, 131, 94, 1);

  // Colores originales de AppColors
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
