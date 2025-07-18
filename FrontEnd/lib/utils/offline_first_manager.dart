import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'local_db.g.dart';

class TechnicalLocations extends Table {
  TextColumn get technicalCode => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get parentTechnicalCode => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {technicalCode};
}

@DriftDatabase(tables: [TechnicalLocations])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD methods
  Future<void> insertLocation(TechnicalLocation location) =>
      into(technicalLocations).insert(location);

  Future<List<TechnicalLocation>> getAllLocations() =>
      select(technicalLocations).get();

  Future<List<TechnicalLocation>> getDirtyLocations() =>
      (select(technicalLocations)..where((tbl) => tbl.dirty.equals(true))).get();

  Future<void> markClean(String code) async {
    await (update(technicalLocations)
      ..where((tbl) => tbl.technicalCode.equals(code)))
      .write(TechnicalLocationsCompanion(dirty: Value(false)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'gema.sqlite'));
    return NativeDatabase(file);
  });
}