import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/widgets/social_profile_header.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.ptBr);

  setUpAll(() {
    HttpOverrides.global = _AvatarHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  SocialProfileModel profile({bool followed = false, String? avatarUrl}) =>
      SocialProfileModel(
        userId: 'user-1',
        displayName: 'Fulano',
        avatarUrl: avatarUrl,
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
    VoidCallback? onFollow,
    VoidCallback? onUnfollow,
    VoidCallback? onEdit,
    VoidCallback? onAvatarEdit,
    bool isAvatarUploading = false,
    String? avatarUrl,
  }) {
    return tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SocialProfileHeader(
              profile: profile(followed: followed, avatarUrl: avatarUrl),
              isMe: isMe,
              onFollow: onFollow,
              onUnfollow: onUnfollow,
              onEdit: onEdit,
              onAvatarEdit: onAvatarEdit,
              isAvatarUploading: isAvatarUploading,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders counts in wrapping layout and edit button variant', (
    tester,
  ) async {
    await pumpHeader(tester, isMe: true, onEdit: () {});

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.text(t.social_followers_count(count: profile().followerCount)),
      findsOneWidget,
    );
    expect(
      find.text(t.social_following_count(count: profile().followingCount)),
      findsOneWidget,
    );
    expect(find.text(t.social_edit_profile), findsOneWidget);
  });

  testWidgets('calls edit callback', (tester) async {
    var calls = 0;
    await pumpHeader(tester, isMe: true, onEdit: () => calls++);

    await tester.tap(find.text(t.social_edit_profile));

    expect(calls, 1);
  });

  testWidgets('keeps fallback initial when avatarUrl is missing', (
    tester,
  ) async {
    await pumpHeader(tester, avatarUrl: '');

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
    expect(find.text('F'), findsOneWidget);
  });

  testWidgets('uses network avatar when avatarUrl is present', (tester) async {
    await pumpHeader(tester, avatarUrl: 'https://example.com/avatar.png');

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    final backgroundImage = avatar.backgroundImage;
    expect(backgroundImage, isA<NetworkImage>());
    expect(
      (backgroundImage! as NetworkImage).url,
      'https://example.com/avatar.png',
    );
    expect(find.text('F'), findsNothing);
  });

  testWidgets('tapping own avatar calls avatar edit callback', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var calls = 0;
      await pumpHeader(tester, isMe: true, onAvatarEdit: () => calls++);

      final avatarSemantics = tester.getSemantics(
        find.byKey(const Key('socialProfileAvatarAction')),
      );
      expect(avatarSemantics.label, 'Edit avatar');
      expect(avatarSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(avatarSemantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
      await tester.tap(find.byKey(const Key('socialProfileAvatarAction')));

      expect(calls, 1);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('uploading overlay disables avatar edit callback', (
    tester,
  ) async {
    var calls = 0;
    await pumpHeader(
      tester,
      isMe: true,
      onAvatarEdit: () => calls++,
      isAvatarUploading: true,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byKey(const Key('socialProfileAvatarAction')));

    expect(calls, 0);
  });

  testWidgets(
    'uploading overlay only renders for editable current-user avatar',
    (tester) async {
      await pumpHeader(tester, isAvatarUploading: true);

      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets('renders follow and unfollow button variants', (tester) async {
    await pumpHeader(tester, onFollow: () {}, onUnfollow: () {});
    expect(find.text(t.social_follow), findsOneWidget);

    await pumpHeader(
      tester,
      followed: true,
      onFollow: () {},
      onUnfollow: () {},
    );
    expect(find.text(t.social_unfollow), findsOneWidget);
  });

  testWidgets('calls follow and unfollow callbacks', (tester) async {
    var followCalls = 0;
    var unfollowCalls = 0;

    await pumpHeader(
      tester,
      onFollow: () => followCalls++,
      onUnfollow: () => unfollowCalls++,
    );
    await tester.tap(find.text(t.social_follow));

    await pumpHeader(
      tester,
      followed: true,
      onFollow: () => followCalls++,
      onUnfollow: () => unfollowCalls++,
    );
    await tester.tap(find.text(t.social_unfollow));

    expect(followCalls, 1);
    expect(unfollowCalls, 1);
  });

  testWidgets('disables follow button when callback is missing', (
    tester,
  ) async {
    await pumpHeader(tester, onUnfollow: () {});

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('disables unfollow button when callback is missing', (
    tester,
  ) async {
    await pumpHeader(tester, followed: true, onFollow: () {});

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}

class _AvatarHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _AvatarHttpClient();
}

class _AvatarHttpClient extends Fake implements HttpClient {
  @override
  set autoUncompress(bool value) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _AvatarHttpClientRequest();
}

class _AvatarHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _AvatarHttpClientResponse();
}

class _AvatarHttpClientResponse extends Stream<List<int>>
    with Fake
    implements HttpClientResponse {
  static final _bytes = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  @override
  int get contentLength => _bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_bytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
