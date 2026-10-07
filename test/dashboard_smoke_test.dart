import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fatma_zahra_thyroid_tracker/features/dashboard/dashboard_page.dart';
import 'package:fatma_zahra_thyroid_tracker/features/state/app_state.dart';
import 'package:fatma_zahra_thyroid_tracker/repositories/health_repository.dart';

void main() {
  testWidgets('le tableau de bord affiche les dernières valeurs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(repo: MemoryRepository.seeded(), prefs: prefs);
    await state.load();

    await tester.binding.setSurfaceSize(const Size(800, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [Locale('fr')],
          home: Scaffold(body: DashboardPage()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('11.93'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('3.5'), findsOneWidget);
    expect(find.textContaining('75 µg'), findsWidgets);
    expect(find.text('À discuter avec le médecin.'), findsOneWidget);
  });
}
