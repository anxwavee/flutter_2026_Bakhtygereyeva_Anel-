import 'models.dart';
sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describe(ShelfState state) {
  return switch (state){
    Empty() => "Shelf is empty",
    Ready(:final books) => "Shelf has ${books.length} books",
    Broken(:final message) => "Shelf is broken. Message: $message",
  };
}

({int count, double avgPages}) statsOf(List<Book> books) {
  int count = books.length;
  double totalPages = books.fold(0, (sum, books) => sum + books.pages);
  double avgPages = totalPages / count;

  return (count: count, avgPages: avgPages);
}



