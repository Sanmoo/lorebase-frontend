import 'package:cached_network_image/cached_network_image.dart';
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
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: Scaffold(
            body: PublicMediaListSection(
              title: 'Favoritos',
              items: items,
              emptyMessage: 'Nada público.',
              onItemTap: onItemTap,
            ),
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
    expect(find.text('Abandonado', skipOffstage: false), findsOneWidget);
    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('Reacher'), findsOneWidget);
    expect(find.text('Batman Begins'), findsOneWidget);
    expect(find.text('Filme • ⭐ 9/10'), findsOneWidget);
    expect(find.text('Série'), findsOneWidget);
    expect(find.text('PLAN_TO_WATCH'), findsNothing);
    expect(find.text('WATCHING'), findsNothing);
    expect(find.text('COMPLETED'), findsNothing);
    expect(find.text('DROPPED'), findsNothing);
    expect(find.byType(ListTile), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders public media cards with bordered aligned layout', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [
        item(
          status: 'COMPLETED',
          title: 'Batman: O Cavaleiro das Trevas',
          rating: 10,
        ),
      ],
    );

    final inkWidgets = tester.widgetList<Ink>(
      find.descendant(of: find.byType(InkWell), matching: find.byType(Ink)),
    );

    expect(
      inkWidgets.any((ink) {
        final decoration = ink.decoration;
        return decoration is BoxDecoration && decoration.border != null;
      }),
      isTrue,
    );
    expect(find.text('Batman: O Cavaleiro das Trevas'), findsOneWidget);
    expect(find.text('Filme • ⭐ 10/10'), findsOneWidget);
  });

  testWidgets('keeps known statuses in stable display order', (tester) async {
    await pumpSection(
      tester,
      items: [
        item(mediaId: '1', status: 'COMPLETED', title: 'Matrix'),
        item(mediaId: '2', status: 'PLAN_TO_WATCH', title: 'Alien'),
        item(mediaId: '3', status: 'DROPPED', title: 'Blade Runner'),
        item(mediaId: '4', status: 'WATCHING', title: 'Reacher'),
      ],
    );

    final textValues = tester
        .widgetList<Text>(find.byType(Text, skipOffstage: false))
        .map((text) => text.data)
        .toList();

    expect(
      textValues.indexOf('Quero ver'),
      lessThan(textValues.indexOf('Assistindo')),
    );
    expect(
      textValues.indexOf('Assistindo'),
      lessThan(textValues.indexOf('Concluído')),
    );
    expect(
      textValues.indexOf('Concluído'),
      lessThan(textValues.indexOf('Abandonado')),
    );
  });

  testWidgets('groups statuses case-insensitively by normalized key', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [
        item(mediaId: '1', status: 'COMPLETED', title: 'Matrix'),
        item(mediaId: '2', status: 'completed', title: 'Alien'),
        item(mediaId: '3', status: 'Completed', title: 'Blade Runner'),
      ],
    );

    expect(find.text('Concluído'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
    expect(find.text('completed'), findsNothing);
    expect(find.text('Matrix'), findsOneWidget);
    expect(find.text('Alien'), findsOneWidget);
    expect(find.text('Blade Runner'), findsOneWidget);
  });

  testWidgets('renders non-empty poster URL with cached network image', (
    tester,
  ) async {
    const posterUrl = 'https://images.example.test/poster.jpg';

    await pumpSection(tester, items: [item(posterUrl: posterUrl)]);

    final cachedImage = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );

    expect(cachedImage.imageUrl, posterUrl);
    expect(cachedImage.fit, BoxFit.cover);
    expect(find.byIcon(Icons.movie), findsNothing);
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

  testWidgets('handles large text scale with title and metadata', (
    tester,
  ) async {
    await pumpSection(
      tester,
      textScaler: const TextScaler.linear(2),
      items: [
        item(
          status: 'COMPLETED',
          title: 'Título longo para testar quebra em duas linhas',
          rating: 8,
          posterUrl: 'https://images.example.test/poster.jpg',
        ),
      ],
    );

    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(
      find.text('Título longo para testar quebra em duas linhas'),
      findsOneWidget,
    );
    expect(find.text('Filme • ⭐ 8/10'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
