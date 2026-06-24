// coverage:ignore-file
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/media_filter_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../l10n/strings.g.dart';
import '../viewmodels/series_search_viewmodel.dart';
import '../widgets/series_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../movies/viewmodels/movie_search_viewmodel.dart';
import '../../movies/widgets/movie_card.dart';
import '../../../../core/widgets/media_type_toggle.dart';
import '../../tracking/data/models/media_type.dart';
import '../../games/viewmodels/game_search_viewmodel.dart';
import '../../games/widgets/game_card.dart';

class SeriesSearchPage extends ConsumerStatefulWidget {
  const SeriesSearchPage({super.key});

  @override
  ConsumerState<SeriesSearchPage> createState() => _SeriesSearchPageState();
}

class _SeriesSearchPageState extends ConsumerState<SeriesSearchPage> {
  Timer? _debounceTimer;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController
      ..removeListener(_onSearchTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  String _searchHintFor(MediaType type) {
    switch (type) {
      case MediaType.series:
        return context.t.search_hint;
      case MediaType.movie:
        return context.t.search_hint_movies;
      case MediaType.game:
        return context.t.search_hint_games;
    }
  }

  void _onTypeChanged(MediaType type) {
    _debounceTimer?.cancel();
    ref.read(selectedMediaTypeProvider.notifier).state = type;
    _searchController.clear();
    ref.read(seriesSearchViewModelProvider.notifier).clear();
    ref.read(movieSearchViewModelProvider.notifier).clear();
    ref.read(gameSearchViewModelProvider.notifier).clear();
  }

  void _onSearchChanged(String query) {
    final selectedType = ref.read(selectedMediaTypeProvider);
    _debounceTimer?.cancel();
    if (query.length >= 2) {
      _debounceTimer = Timer(AppConstants.kSearchDebounceDuration, () {
        final currentType = ref.read(selectedMediaTypeProvider);
        if (currentType == MediaType.series) {
          ref.read(seriesSearchViewModelProvider.notifier).search(query);
        } else if (currentType == MediaType.movie) {
          ref.read(movieSearchViewModelProvider.notifier).search(query);
        } else if (currentType == MediaType.game) {
          ref.read(gameSearchViewModelProvider.notifier).search(query);
        }
      });
    } else if (query.isEmpty) {
      if (selectedType == MediaType.series) {
        ref.read(seriesSearchViewModelProvider.notifier).clear();
      } else if (selectedType == MediaType.movie) {
        ref.read(movieSearchViewModelProvider.notifier).clear();
      } else if (selectedType == MediaType.game) {
        ref.read(gameSearchViewModelProvider.notifier).clear();
      }
    }
  }

  void _onClear() {
    _searchController.clear();
    ref.read(seriesSearchViewModelProvider.notifier).clear();
    ref.read(movieSearchViewModelProvider.notifier).clear();
    ref.read(gameSearchViewModelProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedMediaTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: _searchHintFor(selectedType),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    tooltip: context.t.search_clear_tooltip,
                    icon: const Icon(Icons.clear),
                    onPressed: _onClear,
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: MediaTypeToggle(
              selectedType: selectedType,
              onChanged: _onTypeChanged,
            ),
          ),
          Expanded(
            child: _SearchResultsBody(
              mediaType: selectedType,
              query: _searchController.text,
              onRetry: () => _onSearchChanged(_searchController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsBody extends ConsumerWidget {
  final MediaType mediaType;
  final String query;
  final VoidCallback onRetry;

  const _SearchResultsBody({
    required this.mediaType,
    required this.query,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final seriesState = ref.watch(seriesSearchViewModelProvider);
    final movieState = ref.watch(movieSearchViewModelProvider);
    final gameState = ref.watch(gameSearchViewModelProvider);

    switch (mediaType) {
      case MediaType.series:
        return seriesState.when(
          loading: () => const LoadingWidget(),
          error: (error, _) =>
              AppErrorWidget(message: error.toString(), onRetry: onRetry),
          data: (series) {
            if (series.isEmpty && query.isEmpty) {
              return EmptyStateWidget(
                message: t.search_empty,
                icon: Icons.search,
              );
            }
            if (series.isEmpty) {
              return EmptyStateWidget(
                message: t.search_no_results,
                icon: Icons.search_off,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: series.length,
              itemBuilder: (context, index) {
                final item = series[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SeriesCard(
                    series: item,
                    onTap: item.tmdbId != 0
                        ? () => context.go('/series/${item.tmdbId}')
                        : null,
                  ),
                );
              },
            );
          },
        );
      case MediaType.movie:
        return movieState.when(
          loading: () => const LoadingWidget(),
          error: (error, _) =>
              AppErrorWidget(message: error.toString(), onRetry: onRetry),
          data: (movies) {
            if (movies.isEmpty && query.isEmpty) {
              return EmptyStateWidget(
                message: t.search_empty,
                icon: Icons.search,
              );
            }
            if (movies.isEmpty) {
              return EmptyStateWidget(
                message: t.search_no_results_movies,
                icon: Icons.search_off,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final item = movies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: MovieCard(
                    movie: item,
                    onTap: item.tmdbId != 0
                        ? () => context.push('/movies/${item.tmdbId}')
                        : null,
                  ),
                );
              },
            );
          },
        );
      case MediaType.game:
        return gameState.when(
          loading: () => const LoadingWidget(),
          error: (error, _) =>
              AppErrorWidget(message: error.toString(), onRetry: onRetry),
          data: (games) {
            if (games.isEmpty && query.isEmpty) {
              return EmptyStateWidget(
                message: t.search_empty,
                icon: Icons.search,
              );
            }
            if (games.isEmpty) {
              return EmptyStateWidget(
                message: t.search_no_results_games,
                icon: Icons.search_off,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final item = games[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GameCard(game: item),
                );
              },
            );
          },
        );
    }
  }
}
