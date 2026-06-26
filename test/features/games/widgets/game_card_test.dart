import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/games/data/models/game_model.dart';
import 'package:lorebase/features/games/widgets/game_card.dart';

void main() {
  testWidgets('renders game title, genre, release date, and platforms', (
    tester,
  ) async {
    const game = GameModel(
      gameId: '1',
      title: 'The Witcher 3',
      genre: 'RPG',
      releaseDate: '2015-05-19',
      platforms: ['PC', 'PS5'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GameCard(game: game)),
      ),
    );

    expect(find.text('The Witcher 3'), findsOneWidget);
    expect(find.text('RPG'), findsOneWidget);
    expect(find.text('2015-05-19'), findsOneWidget);
    expect(find.text('PC, PS5'), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    const game = GameModel(gameId: '2', title: 'Hollow Knight');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameCard(game: game, onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(GameCard));
    expect(tapped, true);
  });

  testWidgets('handles missing optional fields', (tester) async {
    const game = GameModel(gameId: '3', title: 'Minimal Game');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GameCard(game: game)),
      ),
    );

    expect(find.text('Minimal Game'), findsOneWidget);
    expect(find.text('RPG'), findsNothing);
    expect(find.text('2015-05-19'), findsNothing);
  });

  testWidgets('errorIcon returns broken image icon', (tester) async {
    Icon? capturedIcon;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          capturedIcon ??= GameCard.errorIcon(context, '', Exception('test')) as Icon;
          return const SizedBox();
        },
      ),
    );
    expect(capturedIcon, isNotNull);
    expect(capturedIcon!.icon, Icons.broken_image);
  });
}
