import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  List<Book> books = [];

  for (Map<String, dynamic> data in rawBooks) {
    books.add(Book.fromJson(data));
  }

  Library library = Library();

  for (Book book in books) {
    library.add(book);
  }

  print('Titles:\n${library.everyTitle}\n');

  print('Newest books:\n${library.newestBooks}\n');

  print('Average pages:\n${library.averagePageCount}\n');

  print('Books by author:\n${library.booksByAuthor}\n');

  print('Author names:\n${library.authorNames}\n');

  print('Genres:\n${library.everyGenre}\n');

  print('Display list:\n${library.display}\n');

  print('Statistics:\n${statsOf(books)}\n');

  print('Shelf states:');
  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('An error was found')));
}