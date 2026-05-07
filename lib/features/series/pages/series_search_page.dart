import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../viewmodels/series_search_viewmodel.dart';
import '../widgets/series_card.dart';

class SeriesSearchPage extends ConsumerStatefulWidget {
  const SeriesSearchPage({super.key});

  @override
  ConsumerState<SeriesSearchPage> createState() => _SeriesSearchPageState();
}

class _SeriesSearchPageState extends ConsumerState<SeriesSearchPage> {
  Timer? _debounceTimer;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        ref.read(seriesSearchViewModelProvider.notifier).search(query);
      });
    } else if (query.isEmpty) {
      ref.read(seriesSearchViewModelProvider.notifier).clear();
    }
  }

  void _onClear() {
    _searchController.clear();
    ref.read(seriesSearchViewModelProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search series...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _onClear,
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _SearchResultsBody(
        query: _searchController.text,
        onRetry: () => _onSearchChanged(_searchController.text),
      ),
    );
  }
}

class _SearchResultsBody extends ConsumerWidget {
  final String query;
  final VoidCallback onRetry;

  const _SearchResultsBody({required this.query, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(seriesSearchViewModelProvider);

    return searchState.when(
      loading: () => const LoadingWidget(),
      error: (error, _) => AppErrorWidget(
        message: error.toString(),
        onRetry: onRetry,
      ),
      data: (series) {
        if (series.isEmpty && query.isEmpty) {
          return const EmptyStateWidget(
            message: 'Type at least 2 characters to search',
            icon: Icons.search,
          );
        }
        if (series.isEmpty) {
          return const EmptyStateWidget(
            message: 'No series found',
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
                    ? () => context.push('/series/${item.tmdbId}')
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
