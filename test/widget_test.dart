import 'package:alternia/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DetAiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DetAiApp), findsOneWidget);
  });
}
