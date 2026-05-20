import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/widgets/public_media_list_section.dart';

void main() {
  PublicListItemModel item({int? rating}) => PublicListItemModel(
    mediaId: 'media-1',
    mediaType: 'tv',
    status: 'completed',
    rating: rating,
    media: const SocialMediaModel(
      mediaId: 'media-1',
      mediaType: 'tv',
      title: 'One Piece',
    ),
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

  testWidgets('renders rating when present', (tester) async {
    await pumpSection(tester, items: [item(rating: 9)]);

    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('completed'), findsOneWidget);
    expect(find.text('⭐ 9/10'), findsOneWidget);
  });

  testWidgets('omits rating when absent and handles taps', (tester) async {
    PublicListItemModel? tapped;
    final listItem = item();

    await pumpSection(
      tester,
      items: [listItem],
      onItemTap: (item) => tapped = item,
    );
    await tester.tap(find.byType(ListTile));

    expect(find.text('⭐ 9/10'), findsNothing);
    expect(tapped, listItem);
  });
}
