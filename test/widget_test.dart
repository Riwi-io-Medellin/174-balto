import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_pets/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BaltoApp(isLoggedIn: false));
    expect(find.byType(BaltoApp), findsOneWidget);
  });
}
