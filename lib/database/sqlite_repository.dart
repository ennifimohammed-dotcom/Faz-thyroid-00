import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../data/seed_data.dart';
import '../repositories/health_repository.dart';
import 'schema.dart';

class SqliteRepository implements HealthRepository {
  SqliteRepository._(this._db);
  final Database _db;

  static Future<SqliteRepository> open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'thyroid_tracker.db'),
      version: 1,
      onCreate: (db, version) async {
        for (final sql in kSchemaSql) {
          await db.execute(sql);
        }
        final batch = db.batch();
        void ins(String table, Map<String, Object?> m) {
          final copy = Map<String, Object?>.from(m)..remove('id');
          batch.insert(table, copy);
        }

        for (final e in seedThyroid) {
          ins(thyroidT.name, e.toMap());
        }
        for (final e in seedOthers) {
          ins(otherT.name, e.toMap());
        }
        for (final e in seedDoseEvents) {
          ins(doseT.name, e.toMap());
        }
        await batch.commit(noResult: true);
      },
    );
    return SqliteRepository._(db);
  }

  @override
  Future<List<T>> all<T>(TableDef<T> t) async {
    final rows = await _db.query(t.name);
    return [for (final r in rows) t.fromMap(r)];
  }

  @override
  Future<int> save<T>(TableDef<T> t, T item) async {
    final m = Map<String, Object?>.from(t.toMap(item));
    final id = m['id'] as int?;
    if (id == null) {
      m.remove('id');
      return _db.insert(t.name, m);
    }
    await _db.insert(t.name, m, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  @override
  Future<void> delete<T>(TableDef<T> t, int id) async {
    await _db.delete(t.name, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<RawTables> dumpRaw() async {
    final out = <String, List<Map<String, Object?>>>{};
    for (final n in kTableNames) {
      final rows = await _db.query(n);
      out[n] = [for (final r in rows) Map<String, Object?>.from(r)];
    }
    return out;
  }

  @override
  Future<void> replaceAll(RawTables data) async {
    await _db.transaction((txn) async {
      for (final n in kTableNames) {
        await txn.delete(n);
        for (final row in data[n] ?? const <Map<String, Object?>>[]) {
          await txn.insert(n, row, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }
}
