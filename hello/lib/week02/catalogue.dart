import 'package:hello/week02/models.dart';

class Library {
  final List<LibraryItem> items = [];

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (LibraryItem item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? "unknown";
  }

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;

  String report() {
    _cachedReport ??=
    'There are ${items.length} items in the library right now';
    return _cachedReport ?? 'No report';
  }

  List<String> get everyTitle => items.map((item) => item.title).toList();

  List<Book> get newestBooks =>
      items.where((item) => item is Book && item.year > 2010).map((
          item) => item as Book).toList();

  double get averagePageCount =>
      items.where((item) => item is Book).fold(0, (sum, item) => sum + (item as Book).pages,) / items.where((item) => item is Book).length;

  Map<String, int> get booksByAuthor {
    Map<String, int> result = {};

    for (LibraryItem item in items) {
      if(item is Book) {
        String author = item.author.name;
        result[author] = (result[author] ?? 0) + 1;
      }
    }
    return result;
  }

  Set<String> get authorNames =>
      items.where((item) => item is Book).map((item) => (item as Book).author.name).toSet();

  Set<Genre> get everyGenre =>
      items.where((item) => item is Book).map((item) => (item as Book).genre).toSet();

  List<String> get display => ['CATALOGUE',
    for (LibraryItem item in items)
      if (item is Book)
        '${item.title} - (${item.year})',

    for (String author in authorNames)
      author,
    if (items.any((item) => item is Book && item.pages == 0))
      '(incomplete data)',
  ];
}
