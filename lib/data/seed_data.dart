import '../models/models.dart';

/// Donnees initiales : copie EXACTE des valeurs fournies (Excel + donnees
/// fournies par l'utilisateur). Aucune valeur n'est arrondie ni corrigee.
/// FT4 = 14 et FT3 = 3.5 sont conserves tels quels.
final List<ThyroidEntry> seedThyroid = [
  ThyroidEntry(date: DateTime(2025, 11, 11), tsh: 20.9, source: kSrcExcel),
  ThyroidEntry(date: DateTime(2026, 1, 17), tsh: 8.48, source: kSrcExcel),
  ThyroidEntry(
      date: DateTime(2026, 5, 8), tsh: 10.9, doseUg: 75, source: kSrcExcel),
  ThyroidEntry(
      date: DateTime(2026, 9, 28),
      tsh: 11.93,
      ft4: 14,
      ft3: 3.5,
      doseUg: 50,
      source: kSrcExcel),
];

final List<OtherAnalysis> seedOthers = [
  OtherAnalysis(
      date: DateTime(2023, 3, 31),
      name: 'Anti-TPO',
      value: 196.5,
      unit: 'UI/mL',
      refMax: 50,
      comment: 'Référence < 50',
      source: kSrcUser),
  OtherAnalysis(
      date: DateTime(2023, 3, 31),
      name: 'Anti-TG',
      value: 79.4,
      unit: 'UI/mL',
      refMax: 100,
      comment: 'Référence < 100',
      source: kSrcUser),
  OtherAnalysis(
      date: DateTime(2023, 4, 9),
      name: 'ACTH',
      value: 16.53,
      unit: 'pg/mL',
      refMin: 7.2,
      refMax: 63.3,
      source: kSrcUser),
  OtherAnalysis(
      date: DateTime(2026, 10, 3),
      name: 'Cortisol matin',
      value: 139.1,
      unit: 'ng/mL',
      refMin: 82.2,
      refMax: 195,
      source: kSrcUser),
];

/// Decision rapportee par l'utilisateur, sans date precise : date = null.
final List<DoseEvent> seedDoseEvents = [
  DoseEvent(
    kind: kDosePrescribed,
    doseUg: 75,
    note:
        'Après le bilan du 28/09/2026, la médecin a remis la dose à 75 µg (date de la décision non précisée).',
    source: kSrcUser,
  ),
];
