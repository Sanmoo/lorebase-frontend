import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/widgets/public_media_list_section.dart';

void main() {
  PublicListItemModel item({
    String mediaId = 'media-1',
    String mediaType = 'MOVIE',
    String status = 'COMPLETED',
    int? rating,
    bool hasMedia = true,
    String title = 'One Piece',
    String? posterUrl,
  }) => PublicListItemModel(
    mediaId: mediaId,
    mediaType: mediaType,
    status: status,
    rating: rating,
    media: hasMedia
        ? SocialMediaModel(
            mediaId: mediaId,
            mediaType: mediaType,
            title: title,
            posterUrl: posterUrl,
          )
        : null,
  );

  Future<void> pumpSection(
    WidgetTester tester, {
    List<PublicListItemModel> items = const [],
    ValueChanged<PublicListItemModel>? onItemTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PublicMediaListSection(
            title: 'Favoritos',
            items: items,
            emptyMessage: 'Nada público.',
            onItemTap: onItemTap,
          ),
        ),
      ),
    );
  }

  testWidgets('renders empty state', (tester) async {
    await pumpSection(tester);

    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Nada público.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('renders list items in friendly horizontal carousels', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [
        item(status: 'PLAN_TO_WATCH', title: 'Interestelar'),
        item(status: 'WATCHING', mediaType: 'SERIES', title: 'Reacher'),
        item(status: 'COMPLETED', title: 'Batman Begins', rating: 9),
        item(status: 'DROPPED', title: 'Série abandonada'),
      ],
    );

    expect(find.text('Quero ver'), findsOneWidget);
    expect(find.text('Assistindo'), findsOneWidget);
    expect(find.text('Concluído'), findsOneWidget);
    expect(find.text('Abandonado'), findsOneWidget);
    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('Reacher'), findsOneWidget);
    expect(find.text('Batman Begins'), findsOneWidget);
    expect(find.text('⭐ 9/10'), findsOneWidget);
    expect(find.text('PLAN_TO_WATCH'), findsNothing);
    expect(find.text('WATCHING'), findsNothing);
    expect(find.text('COMPLETED'), findsNothing);
    expect(find.text('DROPPED'), findsNothing);
    expect(find.byType(ListTile), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('omits rating when absent and handles taps', (tester) async {
    PublicListItemModel? tapped;
    final listItem = item();

    await pumpSection(
      tester,
      items: [listItem],
      onItemTap: (item) => tapped = item,
    );
    await tester.tap(find.text('One Piece'));

    expect(find.text('⭐ 9/10'), findsNothing);
    expect(tapped, listItem);
  });

  testWidgets('item without media shows friendly movie fallback', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [item(mediaType: 'MOVIE', hasMedia: false)],
    );

    expect(find.text('Filme'), findsOneWidget);
    expect(find.text('media-1'), findsNothing);
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });

  testWidgets('scrolls many completed items horizontally without overflow', (
    tester,
  ) async {
    final items = List.generate(
      12,
      (index) =>
          item(mediaId: '$index', status: 'COMPLETED', title: 'Título $index'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 260,
            child: PublicMediaListSection(title: 'Favoritos', items: items),
          ),
        ),
      ),
    );

    final horizontalList = find.byWidgetPredicate(
      (widget) =>
          widget is ListView && widget.scrollDirection == Axis.horizontal,
    );

    expect(tester.takeException(), isNull);
    expect(horizontalList, findsAtLeastNWidgets(1));
    expect(find.text('Título 0'), findsOneWidget);
    expect(find.text('Título 11'), findsNothing);

    await tester.dragUntilVisible(
      find.text('Título 11'),
      horizontalList.first,
      const Offset(-250, 0),
      maxIteration: 10,
    );

    expect(find.text('Título 11'), findsOneWidget);
  });
}
