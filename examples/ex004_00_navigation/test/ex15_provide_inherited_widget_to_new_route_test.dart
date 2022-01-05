import 'package:ex_006_5_navigation/ex15_provide_inherited_widget_to_new_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test navigation logic',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(ItemTile), findsNWidgets(10));
      //
      await tester.tap(find.byType(ItemTile).at(5));
      await tester.pumpAndSettle();
      expect(find.text('Item details: 5'), findsOneWidget);
    },
  );
}
