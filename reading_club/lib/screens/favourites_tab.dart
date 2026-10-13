import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/widgets/book_collection.dart';
import 'package:reading_club/widgets/empty_state.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onToggleFavourite;

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = sortedByDate(books.where((book) => book.isFavourite));
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse books',
        onAction: onBrowse,
      );
    }
    return BookCollection(
      books: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
