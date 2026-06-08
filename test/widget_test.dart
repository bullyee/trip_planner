import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/main.dart';

void main() {
  testWidgets('App boots and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TripPlannerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Trip Planner'), findsOneWidget);
  });
}
