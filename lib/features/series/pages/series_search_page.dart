import 'package:flutter/material.dart';
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.length >= 2) {
      ref.read(seriesSearchViewModelProvider.notifier).search(query);
    } else if (query.isEmpty) {
      ref.read(seriesSearchViewModelProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(seriesSearchViewModelProvider);

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
                    onPressed: () {
                      _searchController.clear();
                      ref.read(seriesSearchViewModelProvider.notifier).clear();
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: searchState.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorWidget(
          message: error.toString(),
          onRetry: () => _onSearchChanged(_searchController.text),
        ),
        data: (series) {
          if (series.isEmpty && _searchController.text.isEmpty) {
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
                  onTap: () {
                    // TODO: Navigate to series detail
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
