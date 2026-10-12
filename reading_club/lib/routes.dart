import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/screens/book_form_screen.dart';
import 'package:reading_club/screens/detail_screen.dart';
import 'package:reading_club/screens/not_found_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch ((settings.name, settings.arguments)) {
      (detail, DetailArgs args) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      ),
      (form, FormArgs args) => MaterialPageRoute<Book>(
        settings: settings,
        builder: (_) => BookFormScreen(book: args.book),
      ),
      _ => null,
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const NotFoundScreen(),
    );
  }
}
