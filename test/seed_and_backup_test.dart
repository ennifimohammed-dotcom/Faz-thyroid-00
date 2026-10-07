import 'package:flutter_test/flutter_test.dart';
import 'package:fatma_zahra_thyroid_tracker/data/seed_data.dart';
import 'package:fatma_zahra_thyroid_tracker/database/schema.dart';
import 'package:fatma_zahra_thyroid_tracker/models/models.dart';
import 'package:fatma_zahra_thyroid_tracker/repositories/health_repository.dart';
import 'package:fatma_zahra_thyroid_tracker/services/backup_service.dart';

void main() {
  test('import Excel : valeurs exactes préservées', () {
    expect(seedThyroid.length, 4);
    final last = seedThyroid.last;
    expect(last.date, DateTime(2026, 9, 28));
    expect(last.tsh, 11.93);
    expect(last.ft4, 14); // pas 14.17
    expect(last.ft3, 3.5); // pas 3.40
    expect(last.doseUg, 50);
    expect(seedThyroid.first.ft4, isNull); // absent, jamais 0
    expect(seedThyroid.first.ft3, isNull);
    expect(seedThyroid[2].doseUg, 75);
  });

  test('données fournies par l\'utilisateur identifiées comme telles', () {
    expect(seedOthers.length, 4);
    expect(seedOthers.every((e) => e.source == kSrcUser), isTrue);
    expect(seedThyroid.every((e) => e.source == kSrcExcel), isTrue);
    expect(seedDoseEvents.single.date, isNull); // date non inventée
  });

  test('sauvegarde : export puis lecture', () async {
    final repo = MemoryRepository.seeded();
    final json = encodeBackup(
      profile: const PatientProfile().toMap(),
      refs: RefRanges.defaults().toMap(),
      tables: await repo.dumpRaw(),
      now: DateTime(2026, 10, 6),
    );
    final b = decodeBackup(json);
    expect(b.tables['thyroid_entries']!.length, 4);
    expect(b.totalRows, 9);

    final other = MemoryRepository();
    await other.replaceAll(b.tables);
    final entries = await other.all(thyroidT);
    expect(entries.last.ft4, 14);
    expect(entries.first.ft4, isNull);
  });

  test('sauvegarde invalide refusée', () {
    expect(() => decodeBackup('pas du json'), throwsFormatException);
    expect(() => decodeBackup('{"format":"autre"}'), throwsFormatException);
  });
}
