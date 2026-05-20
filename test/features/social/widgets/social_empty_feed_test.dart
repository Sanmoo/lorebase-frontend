import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/widgets/social_empty_feed.dart';

void main() {
  testWidgets('renders educational copy and CTA', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialEmptyFeed(onDiscoverTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Seu feed ainda está quieto'), findsOneWidget);
    expect(
      find.text(
        'Siga pessoas para ver avaliações, reviews e atividades recentes.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Descobrir pessoas'));
    expect(tapped, isTrue);
  });
}
