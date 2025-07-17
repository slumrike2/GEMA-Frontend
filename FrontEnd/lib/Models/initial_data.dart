
import 'package:frontend/Models/backend_types.dart';

class InitialData {
  static final Map<String, LocationType> locationTypes = {
    "sede": LocationType(
      name: "Sede",
      nameTemplate: "Sede {nombre}",
      codeTemplate: "SEDE-{codigo}",
      description: "Campus o sede principal",
    ),
    "edificio": LocationType(
      name: "Edificio",
      nameTemplate: "Edificio {letra} - {descripcion}",
      codeTemplate: "EDIF-{letra}",
      description: "Edificio dentro de una sede",
    ),
    "piso": LocationType(
      name: "Piso",
      nameTemplate: "Piso {numero}",
      codeTemplate: "P{numero}",
      description: "Nivel dentro de un edificio",
    ),
    "salon": LocationType(
      name: "Salón",
      nameTemplate: "Salón {numero}",
      codeTemplate: "S-{numero}",
      description: "Aula o salón de clases",
    ),
    "laboratorio": LocationType(
      name: "Laboratorio",
      nameTemplate: "Laboratorio de {especialidad}",
      codeTemplate: "LAB-{codigo}",
      description: "Laboratorio especializado",
    ),
    "oficina": LocationType(
      name: "Oficina",
      nameTemplate: "Oficina {numero}",
      codeTemplate: "OF-{numero}",
      description: "Oficina administrativa",
    ),
  };

  static final Map<int, Brand> brands = {
    1: Brand(id: 1, name: "Carrier"),
    2: Brand(id: 2, name: "LG"),
    3: Brand(id: 3, name: "Dell"),
    4: Brand(id: 4, name: "HP"),
    5: Brand(id: 5, name: "Samsung"),
  };

  static final Map<String, TechnicalLocation> technicalLocations = {
    "SEDE-GY": TechnicalLocation(
      technicalCode: "SEDE-GY",
      name: "Sede Guayana",
      type: 1, // sede type
      parentTechnicalCode: null,
    ),
    "EDIF-A": TechnicalLocation(
      technicalCode: "EDIF-A",
      name: "Edificio A - Administración",
      type: 2, // edificio type
      parentTechnicalCode: "SEDE-GY",
    ),
    "EDIF-B": TechnicalLocation(
      technicalCode: "EDIF-B",
      name: "Edificio B - Aulas",
      type: 2, // edificio type
      parentTechnicalCode: "SEDE-GY",
    ),
    "P1-A": TechnicalLocation(
      technicalCode: "P1-A",
      name: "Piso 1 - Edificio A",
      type: 3, // piso type
      parentTechnicalCode: "EDIF-A",
    ),
    "P2-A": TechnicalLocation(
      technicalCode: "P2-A",
      name: "Piso 2 - Edificio A",
      type: 3, // piso type
      parentTechnicalCode: "EDIF-A",
    ),
    "P1-B": TechnicalLocation(
      technicalCode: "P1-B",
      name: "Piso 1 - Edificio B",
      type: 3, // piso type
      parentTechnicalCode: "EDIF-B",
    ),
    "S-101": TechnicalLocation(
      technicalCode: "S-101",
      name: "Salón 101",
      type: 4, // salon type
      parentTechnicalCode: "P1-A",
    ),
    "OF-102": TechnicalLocation(
      technicalCode: "OF-102",
      name: "Oficina 102",
      type: 6, // oficina type
      parentTechnicalCode: "P1-A",
    ),
    "S-201": TechnicalLocation(
      technicalCode: "S-201",
      name: "Salón 201",
      type: 4, // salon type
      parentTechnicalCode: "P2-A",
    ),
    "LAB-101": TechnicalLocation(
      technicalCode: "LAB-101",
      name: "Laboratorio de Computación",
      type: 5, // laboratorio type
      parentTechnicalCode: "P1-B",
    ),
  };

  static final Map<String, Equipment> equipment = {
    "AC-001": Equipment(
      uuid: "eq-001",
      technicalCode: "AC-001",
      name: "Aire Acondicionado Central",
      serialNumber: "CAR-2024-001",
      brandId: 1, // Carrier
      description: "Sistema de climatización central de 24000 BTU",
      technicalLocation: "P1-A",
      state: EquipmentState.instalado,
    ),
    "PC-001": Equipment(
      uuid: "eq-002",
      technicalCode: "PC-001",
      name: "Computadora de Escritorio",
      serialNumber: "DELL-2024-002",
      brandId: 3, // Dell
      description: "PC Dell OptiPlex para uso administrativo",
      technicalLocation: "OF-102",
      transferLocation: "S-201",
      state: EquipmentState.transferencia_pendiente,
    ),
    "IMP-001": Equipment(
      uuid: "eq-003",
      technicalCode: "IMP-001",
      name: "Impresora Multifuncional",
      serialNumber: "HP-2024-003",
      brandId: 4, // HP
      description: "Impresora HP LaserJet multifuncional",
      state: EquipmentState.en_inventario,
    ),
  };

  static final List<EquipmentOperationalLocation> operationalLocations = [
    EquipmentOperationalLocation(
      id: 1,
      equipmentId: "eq-001",
      locationId: "S-101",
    ),
    EquipmentOperationalLocation(
      id: 2,
      equipmentId: "eq-001",
      locationId: "OF-102",
    ),
    EquipmentOperationalLocation(
      id: 3,
      equipmentId: "eq-002",
      locationId: "OF-102",
    ),
  ];

  static final List<TechnicianSpeciality> technicianSpecialities = [
    TechnicianSpeciality(
      codeName: "HVAC",
      description: "Sistemas de climatización y ventilación",
    ),
    TechnicianSpeciality(codeName: "ELEC", description: "Sistemas eléctricos"),
    TechnicianSpeciality(
      codeName: "COMP",
      description: "Equipos de computación",
    ),
    TechnicianSpeciality(
      codeName: "PLUMB",
      description: "Sistemas de plomería",
    ),
  ];

  static final List<User> users = [
    User(
      uuid: "user-001",
      name: "Juan Pérez",
      email: "juan.perez@ucab.edu.ve",
      role: UserRole.technician,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      uuid: "user-002",
      name: "María González",
      email: "maria.gonzalez@ucab.edu.ve",
      role: UserRole.coordinator,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    User(
      uuid: "user-003",
      name: "Carlos Rodríguez",
      email: "carlos.rodriguez@ucab.edu.ve",
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];
}
