import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/shared/widgets/pop_in.dart';

void main() {
  testWidgets('the child is present immediately and stays present once '
      'the pop-in settles', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PopIn(child: Text('star'))),
    );

    expect(find.text('star'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('star'), findsOneWidget);
  });

  testWidgets('scales up from smaller than final size during the animation',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PopIn(child: Text('star'))),
    );

    // Very early in the 450ms animation: still scaling in, not yet at
    // (or past, thanks to the elastic overshoot) full size.
    await tester.pump(const Duration(milliseconds: 30));
    final early = tester.widget<Transform>(find.byType(Transform));
    expect(early.transform.getMaxScaleOnAxis(), lessThan(1.0));

    await tester.pumpAndSettle();
  });
}
