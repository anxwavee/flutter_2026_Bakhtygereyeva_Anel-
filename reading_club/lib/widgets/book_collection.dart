import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/widgets/book_card.dart';

class BookCollection extends StatelessWidget {
  const BookCollection({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  static const gridBreakpoint = 600.0;
  static const maxCellWidth = 360.0;

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onToggleFavourite;

  Widget _card(Book book) {
    return BookCard(
      book: book,
      onTap: () => onOpen(book),
      onToggleFavourite: () => onToggleFavourite(book),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= gridBreakpoint) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCellWidth,
              childAspectRatio: 2.2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) => _card(books[index]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
          itemCount: books.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) => _card(books[index]),
        );
      },
    );
  }
}
