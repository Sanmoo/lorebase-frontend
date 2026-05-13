import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/widgets/movie_card.dart';

void main() {
  testWidgets('renders movie title and release date', (tester) async {
    const movie = MovieModel(
      tmdbId: 1,
      title: 'Movie Title',
      releaseDate: '2024-01-01',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MovieCard(movie: movie)),
      ),
    );

    expect(find.text('Movie Title'), findsOneWidget);
    expect(find.text('2024-01-01'), findsOneWidget);
  });
}
