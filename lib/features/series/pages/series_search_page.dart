// coverage:ignore-file
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class SeriesSearchPage extends ConsumerStatefulWidget {
  const SeriesSearchPage({super.key});

  @override
  ConsumerState<SeriesSearchPage> createState() => _SeriesSearchPageState();
}

class _SeriesSearchPageState extends ConsumerState<SeriesSearchPage> {
  Timer? _debounceTimer;
  final _searchController = TextEditingController();
  MediaType _selectedType = MediaType.series;

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

  void _onTypeChanged(MediaType type) {
    setState(() {
      _selectedType = type;
    });
    _searchController.clear();
    ref.read(seriesSearchViewModelProvider.notifier).clear();
    ref.read(movieSearchViewModelProvider.notifier).clear();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.length >= 2) {
      _debounceTimer = Timer(AppConstants.kSearchDebounceDuration, () {
        if (_selectedType == MediaType.series) {
          ref.read(seriesSearchViewModelProvider.notifier).search(query);
        } else {
          ref.read(movieSearchViewModelProvider.notifier).search(query);
        }
      });
    } else if (query.isEmpty) {
      if (_selectedType == MediaType.series) {
        ref.read(seriesSearchViewModelProvider.notifier).clear();
      } else {
        ref.read(movieSearchViewModelProvider.notifier).clear();
      }
    }
  }

  void _onClear() {
    _searchController.clear();
    ref.read(seriesSearchViewModelProvider.notifier).clear();
    ref.read(movieSearchViewModelProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: _selectedType == MediaType.series
                ? context.t.search_hint
                : context.t.search_hint_movies,
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
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
              selectedType: _selectedType,
              onChanged: _onTypeChanged,
            ),
          ),
          Expanded(
            child: _SearchResultsBody(
              mediaType: _selectedType,
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

    if (mediaType == MediaType.series) {
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
    } else {
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
    }
  }
}
