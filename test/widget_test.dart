import 'package:flutter_test/flutter_test.dart';
import 'package:petalert/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const PetAlertApp());
    expect(find.text('PetAlert'), findsOneWidget);
  });
}
