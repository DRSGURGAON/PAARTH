import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/shared/widgets/shake_widget.dart';

void main() {
  ShakeWidgetState stateOf(WidgetTester tester) =>
      tester.state<ShakeWidgetState>(find.byType(ShakeWidget));

  testWidgets('sits still until shakeSignal changes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShakeWidget(shakeSignal: 0, child: Text('hello')),
      ),
    );

    expect(stateOf(tester).offset.value, 0);
    await tester.pump(const Duration(milliseconds: 100));
    expect(stateOf(tester).offset.value, 0);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('changing shakeSignal plays a shake that settles back to 0',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShakeWidget(shakeSignal: 0, child: Text('hello')),
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ShakeWidget(shakeSignal: 1, child: Text('hello')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));

    // Mid-shake: the widget has actually moved off-center.
    expect(stateOf(tester).offset.value, isNot(0));

    await tester.pumpAndSettle();
    expect(stateOf(tester).offset.value, 0);
    // The wrapped content is never replaced, just translated.
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('the same shakeSignal value again does not re-trigger',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShakeWidget(shakeSignal: 2, child: Text('hello')),
      ),
    );
    await tester.pumpAndSettle();
    expect(stateOf(tester).offset.value, 0);

    await tester.pumpWidget(
      const MaterialApp(
        home: ShakeWidget(shakeSignal: 2, child: Text('hello')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));

    expect(stateOf(tester).offset.value, 0);
  });
}
