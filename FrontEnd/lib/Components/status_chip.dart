import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/constants/app_constnats.dart';

class StatusChip extends StatelessWidget {
  final EquipmentState? equipmentState;
  final ReportPriority? reportPriority;
  final ReportState? reportState;
  final UserRole? userRole;

  const StatusChip({
    super.key,
    this.equipmentState,
    this.reportPriority,
    this.reportState,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (equipmentState != null) {
      color = AppConstants.equipmentStateColors[equipmentState!]!;
      text = _getEquipmentStateText(equipmentState!);
    } else if (reportPriority != null) {
      color = AppConstants.reportPriorityColors[reportPriority!]!;
      text = _getReportPriorityText(reportPriority!);
    } else if (reportState != null) {
      color = AppConstants.reportStateColors[reportState!]!;
      text = _getReportStateText(reportState!);
    } else if (userRole != null) {
      color = AppConstants.userRoleColors[userRole!]!;
      text = _getUserRoleText(userRole!);
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getEquipmentStateText(EquipmentState state) {
    switch (state) {
      case EquipmentState.instalado:
        return 'Instalado';
      case EquipmentState.en_mantenimiento:
        return 'En Mantenimiento';
      case EquipmentState.mantenimiento_pendiente:
        return 'Mantenimiento Pendiente';
      case EquipmentState.en_reparaciones:
        return 'En Reparaciones';
      case EquipmentState.reparaciones_pendientes:
        return 'Reparaciones Pendientes';
      case EquipmentState.en_inventario:
        return 'En Inventario';
      case EquipmentState.descomisionado:
        return 'Descomisionado';
      case EquipmentState.transferencia_pendiente:
        return 'Transferencia Pendiente';
    }
  }

  String _getReportPriorityText(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.high:
        return 'Alta';
      case ReportPriority.medium:
        return 'Media';
      case ReportPriority.low:
        return 'Baja';
    }
  }

  String _getReportStateText(ReportState state) {
    switch (state) {
      case ReportState.pending:
        return 'Pendiente';
      case ReportState.programmed:
        return 'Programado';
      case ReportState.inProgress:
        return 'En Progreso';
      case ReportState.solved:
        return 'Resuelto';
      case ReportState.cancelled:
        return 'Cancelado';
    }
  }

  String _getUserRoleText(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'Usuario';
      case UserRole.technician:
        return 'Técnico';
      case UserRole.coordinator:
        return 'Coordinador';
      case UserRole.admin:
        return 'Administrador';
    }
  }
}
