import 'package:flutter/material.dart';

enum BookGenre {
  fiction('Fiction', Icons.auto_stories),
  mystery('Mystery', Icons.search),
  sciFi('Sci-Fi', Icons.rocket_launch),
  history('History', Icons.account_balance),
  poetry('Poetry', Icons.edit_note);

  const BookGenre(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    BookGenre.fiction => scheme.primary,
    BookGenre.mystery => scheme.tertiary,
    BookGenre.sciFi => scheme.secondary,
    BookGenre.history => scheme.error,
    BookGenre.poetry => scheme.outline,
  };
}
