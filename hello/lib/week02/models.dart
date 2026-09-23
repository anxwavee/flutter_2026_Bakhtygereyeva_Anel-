class Author {
  final String name;
  final String? country;

  const Author(this.name, this.country);

  @override
  String toString() {
    return '$name - $country';
  }
}

enum Genre {
  craft("craft"),
  theory("theory"),
  unknown("unknown");

  final String label;
  const Genre(this.label);

  static Genre fromString(String? raw){
    if(raw == 'craft') {
      return Genre.craft;
    } else if (raw == 'theory'){
      return Genre.theory;
    } else {
      return Genre.unknown;
    }
  }
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  Ghost({ required this.title, required this.year });

  @override
  String describe() {
    return '$title made in $year';
  }

  @override
  bool get isOld => year < 2000;
}

class Magazine extends LibraryItem  with Borrowable {
  final int issue;

  Magazine({required super.title, required super.year, required this.issue});

  @override
  String describe() {
    return '$title - $year, issue: $issue';
  }
}

class Book extends LibraryItem {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description
  });

  @override
  String describe() {
    return '$title - $author: written in $year with $pages pages';
  }

  factory Book.fromJson(Map<String, dynamic> j) {
    return Book(
        title: j['title'] as String? ?? "No title or Unknown",
        year: j['year'] as int? ?? 0,
        pages: j['pages'] as int? ?? 0,
        author: Author(
          j['author'] as String? ?? 'Unknown author',
          null,
        ),
        genre: Genre.fromString(j['genre']),
        description: j['description'] as String? ?? "No description",
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  })=>
      Book(title: title ?? this.title,
          year: year ?? this.year,
          pages: pages ?? this.pages,
          author: author ?? this.author,
          genre: genre ?? this.genre
      );
  @override
  String toString() {
    return '$title - $author: $year and $pages, description: $description';
  }
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({ required this.title, required this.year });

  String describe();
  bool get isOld => year < 2005;
}

mixin Borrowable on LibraryItem {
  String borrowable() {
    return 'Can borrow: $title';
  }
}

