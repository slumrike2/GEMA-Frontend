import 'package:frontend/Models/backend_types.dart';
import 'template_processor.dart';

class SearchUtils {
  static List<TechnicalLocation> filterLocations(
    String searchTerm,
    Map<String, TechnicalLocation> locations,
    Map<String, LocationType> locationTypes,
  ) {
    if (searchTerm.isEmpty) return locations.values.toList();

    final Map<String, TechnicalLocation> filtered = {};

    for (final location in locations.values) {
      final fullPath = TemplateProcessor.getFullPath(
        location.technicalCode,
        locations,
      );
      final typeName = locationTypes.containsKey(location.type)
          ? TemplateProcessor.getLocationTypeName(
              location.type,
              locationTypes,
            )
          : '';

      final matchesSearch =
          location.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          location.technicalCode.toLowerCase().contains(
            searchTerm.toLowerCase(),
          ) ||
          fullPath.toLowerCase().contains(searchTerm.toLowerCase()) ||
          typeName.toLowerCase().contains(searchTerm.toLowerCase());

      if (matchesSearch) {
        filtered[location.technicalCode] = location;
        // Include parents to maintain structure
        String? parentCode = location.parentTechnicalCode;
        while (parentCode != null && !filtered.containsKey(parentCode)) {
          final parent = locations[parentCode];
          if (parent != null) {
            filtered[parentCode] = parent;
            parentCode = parent.parentTechnicalCode;
          } else {
            break;
          }
        }
      }
    }

    return filtered.values.toList();
  }

  static Map<String, Equipment> filterEquipment(
    String searchTerm,
    Map<String, Equipment> equipment,
    Map<int, Brand> brands,
  ) {
    if (searchTerm.isEmpty) return equipment;

    return Map.fromEntries(
      equipment.entries.where((entry) {
        final eq = entry.value;
        final brandName = TemplateProcessor.getBrandName(eq.brandId, brands);

        return eq.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
            eq.technicalCode.toLowerCase().contains(searchTerm.toLowerCase()) ||
            eq.serialNumber.toLowerCase().contains(searchTerm.toLowerCase()) ||
            brandName.toLowerCase().contains(searchTerm.toLowerCase());
      }),
    );
  }

  static List<Report> filterReports(String searchTerm, List<Report> reports) {
    if (searchTerm.isEmpty) return reports;

    return reports.where((report) {
      return report.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
          report.description.toLowerCase().contains(searchTerm.toLowerCase()) ||
          (report.notes?.toLowerCase().contains(searchTerm.toLowerCase()) ??
              false);
    }).toList();
  }
}
