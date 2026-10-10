import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/utils/format.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookAvatar(book: book),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(book.meetingAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      book.isOnline ? 'Online meeting' : book.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: book.isFavourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                color: theme.colorScheme.primary,
                icon: Icon(
                  book.isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookAvatar extends StatelessWidget {
  const _BookAvatar({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: scheme.surfaceContainerHighest,
          child: Icon(book.genre.icon, color: book.genre.color(scheme)),
        ),
        if (book.isFull)
          Positioned(
            right: -6,
            bottom: -4,
            child: _Badge(
              label: 'FULL',
              background: scheme.error,
              foreground: scheme.onError,
            ),
          )
        else if (book.freeCopies <= 5)
          Positioned(
            right: -6,
            bottom: -4,
            child: _Badge(
              label: '${book.freeCopies} left',
              background: scheme.tertiary,
              foreground: scheme.onTertiary,
            ),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground),
      ),
    );
  }
}
