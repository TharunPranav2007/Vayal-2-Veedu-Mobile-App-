import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vayal2veedu/main.dart';

void main() {
  testWidgets('Vayal2VeeduApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Vayal2VeeduApp(),
      ),
    );

    expect(find.byType(Vayal2VeeduApp), findsOneWidget);
  });
}
