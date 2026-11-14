import 'package:flutter_test/flutter_test.dart';
import 'package:findit_campus/main.dart';

void main() {
  testWidgets('FindIT Campus smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FindITCampusApp());
    expect(find.text('FindIT Campus'), findsWidgets);
  });
}
