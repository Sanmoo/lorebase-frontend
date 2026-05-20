import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/widgets/social_profile_header.dart';

void main() {
  SocialProfileModel profile({bool followed = false}) => SocialProfileModel(
    userId: 'user-1',
    displayName: 'Fulano',
    isPublic: true,
    followingCount: 3,
    followerCount: 7,
    isFollowedByMe: followed,
    createdAt: DateTime(2026, 5, 20),
    updatedAt: DateTime(2026, 5, 20),
  );

  Future<void> pumpHeader(
    WidgetTester tester, {
    bool isMe = false,
    bool followed = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialProfileHeader(
            profile: profile(followed: followed),
            isMe: isMe,
            onFollow: () {},
            onUnfollow: () {},
            onEdit: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders counts and edit button variant', (tester) async {
    await pumpHeader(tester, isMe: true);

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.text('7 seguidores'), findsOneWidget);
    expect(find.text('3 seguindo'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
  });

  testWidgets('renders follow and unfollow button variants', (tester) async {
    await pumpHeader(tester);
    expect(find.text('Seguir'), findsOneWidget);

    await pumpHeader(tester, followed: true);
    expect(find.text('Deixar de seguir'), findsOneWidget);
  });
}
