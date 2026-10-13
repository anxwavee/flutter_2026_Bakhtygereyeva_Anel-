import 'package:flutter/material.dart';
import 'package:reading_club/data/seed.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/models/profile.dart';
import 'package:reading_club/routes.dart';
import 'package:reading_club/screens/book_form_screen.dart';
import 'package:reading_club/screens/book_tab.dart';
import 'package:reading_club/screens/detail_screen.dart';
import 'package:reading_club/screens/favourites_tab.dart';
import 'package:reading_club/screens/profile_tab.dart';
import 'package:reading_club/widgets/app_drawer.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _titles = ['Reading Club', 'Favourites', 'Profile'];
  static const _profileTab = 2;

  List<Book> _books = seedBooks();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _goToTab(int index) => setState(() => _tab = index);

  void _replaceBook(Book updated) {
    final books = [
      for (final book in _books) book.id == updated.id ? updated : book,
    ];
    setState(() => _books = books);
  }

  void _deleteBook(Book deleted) {
    final books = _books.where((book) => book.id != deleted.id).toList();
    setState(() => _books = books);
  }

  void _toggleFavourite(Book book) {
    _replaceBook(book.copyWith(isFavourite: !book.isFavourite));
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  void _openDetail(Book book) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        book: book,
        userName: _profile.name,
        onChanged: _replaceBook,
        onDelete: _deleteBook,
        onOpenProfile: () => _goToTab(_profileTab),
      ),
    );
  }

  Future<void> _addBook() async {
    final created = await Navigator.pushNamed<Book>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null) return;
    if (!mounted) return;
    setState(() => _books = [..._books, created]);
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.menu_book),
        title: const Text('Reading Club'),
        content: const Text(
          'Borrow copies for the club meetings, keep your favourite books '
          'and see who is reading what. All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All books go back to the starting list and your profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    final seed = seedBooks();
    setState(() {
      _books = seed;
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: AppDrawer(onAbout: _showAbout, onReset: _resetData),
      body: switch (_tab) {
        0 => BooksTab(
          books: _books,
          onOpen: _openDetail,
          onToggleFavourite: _toggleFavourite,
        ),
        1 => FavouritesTab(
          books: _books,
          onOpen: _openDetail,
          onToggleFavourite: _toggleFavourite,
          onBrowse: () => _goToTab(0),
        ),
        _ => ProfileTab(
          profile: _profile,
          books: _books,
          themeMode: widget.themeMode,
          onProfileChanged: _setProfile,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      },
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _addBook,
              icon: const Icon(Icons.add),
              label: const Text('New book'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
