import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/models/genre.dart';
import 'package:reading_club/widgets/book_collection.dart';
import 'package:reading_club/widgets/empty_state.dart';

class BooksTab extends StatefulWidget {
  const BooksTab({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onToggleFavourite;

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  final _searchController = TextEditingController();
  String _query = '';
  BookGenre? _genre; // null means "All"
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  List<Book> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    final matching = widget.books.where(
      (book) =>
          (_showPast || !book.isPast) &&
          (_genre == null || book.genre == _genre) &&
          book.title.toLowerCase().contains(query),
    );
    return sortedByDate(matching);
  }

  @override
  Widget build(BuildContext context) {
    final books = _visibleBooks;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _genre == null,
                onSelected: (_) => setState(() => _genre = null),
              ),
              for (final genre in BookGenre.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(genre.icon),
                  label: Text(genre.label),
                  selected: _genre == genre,
                  onSelected: (_) => setState(() => _genre = genre),
                ),
              ],
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: books.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No books match',
                  actionLabel: 'Clear search',
                  onAction: _clearSearch,
                )
              : BookCollection(
                  books: books,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }
}
