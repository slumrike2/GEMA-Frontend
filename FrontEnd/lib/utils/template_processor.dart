import 'package:frontend/Models/backend_types.dart';

class TemplateProcessor {
  static String processTemplate(
    String template,
    Map<String, String> variables,
  ) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  static String getFullPath(
    String technicalCode,
    Map<String, TechnicalLocation> locations,
  ) {
    final location = locations[technicalCode];
    if (location == null) return "";

    final List<String> path = [location.technicalCode];
    String? currentParent = location.parentTechnicalCode;

    while (currentParent != null) {
      final parent = locations[currentParent];
      if (parent != null) {
        path.insert(0, parent.technicalCode);
        currentParent = parent.parentTechnicalCode;
      } else {
        break;
      }
    }

    return path.join(" → ");
  }

  static String getBrandName(int brandId, Map<int, Brand> brands) {
    return brands[brandId]?.name ?? "Sin marca";
  }

  static String getLocationName(
    String? technicalCode,
    Map<String, TechnicalLocation> locations,
  ) {
    if (technicalCode == null) return "Sin ubicación";
    return locations[technicalCode]?.name ?? "Ubicación no encontrada";
  }

  static String getLocationTypeName(
    int typeId,
    Map<String, LocationType> types,
  ) {
    // Assuming type IDs map to location type names
    final typeNames = {
      1: "sede",
      2: "edificio",
      3: "piso",
      4: "salon",
      5: "laboratorio",
      6: "oficina",
    };

    final typeName = typeNames[typeId] ?? "default";
    return types[typeName]?.name ?? "Tipo desconocido";
  }

  static List<String> getChildLocations(
    String parentCode,
    Map<String, TechnicalLocation> locations,
  ) {
    return locations.values
        .where((location) => location.parentTechnicalCode == parentCode)
        .map((location) => location.technicalCode)
        .toList();
  }

  static List<Equipment> getEquipmentInLocation(
    String locationCode,
    Map<String, Equipment> equipment,
  ) {
    return equipment.values
        .where((eq) => eq.technicalLocation == locationCode)
        .toList();
  }

  static List<Equipment> getEquipmentOperatingInLocation(
    String locationCode,
    Map<String, Equipment> equipment,
    List<EquipmentOperationalLocation> operationalLocations,
  ) {
    final equipmentIds =
        operationalLocations
            .where((op) => op.locationId == locationCode)
            .map((op) => op.equipmentId)
            .toSet();

    return equipment.values
        .where((eq) => equipmentIds.contains(eq.uuid))
        .toList();
  }
}
