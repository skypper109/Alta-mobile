import 'package:alternia/features/culture/presentation/screens/culture_contribution_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({required Size screenSize}) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            padding: const EdgeInsets.all(0),
            viewInsets: EdgeInsets.zero,
          ),
          child: const Scaffold(
            body: CultureContributionScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'CultureContributionScreen renders without RenderFlex overflow on standard mobile (360x740)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(screenSize: const Size(360, 740)));
    await tester.pumpAndSettle();

    // Verify key titles and labels are rendered
    expect(find.text('Contribuer au Patrimoine'), findsOneWidget);
    expect(find.text('3. Origine & Attestation du Savoir'), findsOneWidget);
    expect(find.text('Région du Mali *'), findsOneWidget);
    expect(find.text('Votre Rôle'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'CultureContributionScreen renders without overflow on tablet screen (900x1200)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(screenSize: const Size(900, 1200)));
    await tester.pumpAndSettle();

    expect(find.text('Contribuer au Patrimoine'), findsOneWidget);
    expect(find.text('3. Origine & Attestation du Savoir'), findsOneWidget);
    expect(find.text('Région du Mali *'), findsOneWidget);
    expect(find.text('Votre Rôle'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Dropdowns for Region and Role can be opened without RenderFlex overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(screenSize: const Size(360, 740)));
    await tester.pumpAndSettle();

    // Scroll to the dropdowns
    final regionDropdown = find.text('Bamako');
    await tester.ensureVisible(regionDropdown);
    await tester.pumpAndSettle();

    // Tap on the Region dropdown
    await tester.tap(regionDropdown);
    await tester.pumpAndSettle();

    // Verify Ségou option is present
    expect(find.text('Ségou'), findsWidgets);

    // Select Ségou
    await tester.tap(find.text('Ségou').last);
    await tester.pumpAndSettle();

    expect(find.text('Ségou'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
