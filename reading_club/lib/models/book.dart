import 'package:reading_club/models/genre.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.genre,
    required this.meetingAt,
    required this.place,
    required this.copies,
    this._readers = const [],
    this.isOnline = false,
    this.notes,
    this.isFavourite = false,
  });

  Book.empty()
    : id = '',
      title = '',
      genre = BookGenre.fiction,
      meetingAt = DateTime.now().add(const Duration(days: 7)),
      place = '',
      copies = 10,
      _readers = const [],
      isOnline = false,
      notes = null,
      isFavourite = false;

  final String id;
  final String title;
  final BookGenre genre;
  final DateTime meetingAt;

  final String place;
  final int copies;
  final List<String> _readers;
  final bool isOnline;
  final String? notes;
  final bool isFavourite;

  List<String> get readers => List.unmodifiable(_readers);

  int get readerCount => _readers.length;
  int get freeCopies => copies - readerCount;
  bool get isFull => freeCopies <= 0;
  bool get isPast => meetingAt.isBefore(DateTime.now());

  bool contains(String name) => _readers.contains(name);

  ({int taken, int free}) get places => (taken: readerCount, free: freeCopies);

  Book copyWith({
    String? id,
    String? title,
    BookGenre? genre,
    DateTime? meetingAt,
    String? place,
    int? copies,
    List<String>? readers,
    bool? isOnline,
    String? notes,
    bool? isFavourite,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      meetingAt: meetingAt ?? this.meetingAt,
      place: place ?? this.place,
      copies: copies ?? this.copies,
      readers: readers ?? _readers,
      isOnline: isOnline ?? this.isOnline,
      notes: notes ?? this.notes,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}

List<Book> sortedByDate(Iterable<Book> books) {
  return [...books]..sort((a, b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.meetingAt.compareTo(b.meetingAt);
  });
}
