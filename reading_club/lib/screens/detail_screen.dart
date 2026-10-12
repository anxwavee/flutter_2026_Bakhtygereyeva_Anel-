import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/models/countdown.dart';
import 'package:reading_club/routes.dart';
import 'package:reading_club/screens/book_form_screen.dart';
import 'package:reading_club/utils/format.dart';
import 'package:reading_club/widgets/empty_state.dart';

class DetailArgs {
  const DetailArgs({
    required this.book,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Book book;
  final String userName;
  final ValueChanged<Book> onChanged;
  final ValueChanged<Book> onDelete;
  final VoidCallback onOpenProfile;
}

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Book _book = widget.args.book;
  late Countdown _countdown = Countdown.at(_book.meetingAt, DateTime.now());
  late final Timer _timer;

  String get _userName => widget.args.userName.trim();

  bool get _isMine => _userName.isNotEmpty && _book.contains(_userName);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _tick() {
    final next = Countdown.at(_book.meetingAt, DateTime.now());
    setState(() => _countdown = next);
  }

  void _update(Book book) {
    final countdown = Countdown.at(book.meetingAt, DateTime.now());
    setState(() {
      _book = book;
      _countdown = countdown;
    });
    widget.args.onChanged(book);
  }

  void _openProfile() {
    if (mounted) Navigator.pop(context);
    widget.args.onOpenProfile();
  }

  Future<void> _borrow() async {
    if (_userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrow this book?'),
        content: Text(
          'A copy of "${_book.title}" will be kept for $_userName.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrow'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    _update(_book.copyWith(readers: [..._book.readers, _userName]));
  }

  void _giveBack() {
    _update(
      _book.copyWith(
        readers: _book.readers.where((name) => name != _userName).toList(),
      ),
    );
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<Book>(
      context,
      Routes.form,
      arguments: FormArgs(book: _book),
    );
    if (edited == null) return;
    if (!mounted) return;
    _update(edited);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this book?'),
        content: Text('"${_book.title}" and its readers list will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    widget.args.onDelete(_book);
    Navigator.pop(context);
  }

  void _onMenu(_MenuAction action) {
    switch (action) {
      case _MenuAction.edit:
        _edit();
      case _MenuAction.delete:
        _delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MenuAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(book: _book, countdown: _countdown),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Readers (${_book.readerCount})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(book: _book),
                  _ReadersTab(book: _book, userName: _userName),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isMine
                ? FilledButton.tonalIcon(
                    onPressed: _giveBack,
                    icon: const Icon(Icons.undo),
                    label: const Text('Give back'),
                  )
                : FilledButton.icon(
                    onPressed: _book.isFull ? null : _borrow,
                    icon: const Icon(Icons.bookmark_add),
                    label: Text(_book.isFull ? 'No copies left' : 'Borrow'),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.book, required this.countdown});

  final Book book;
  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              child: Icon(
                book.genre.icon,
                size: 36,
                color: book.genre.color(scheme),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(
              avatar: Icon(book.genre.icon),
              label: Text(book.genre.label),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Chip(
              avatar: const Icon(Icons.schedule),
              label: Text(describeCountdown(countdown)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = book.places;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(book.meetingAt)),
          subtitle: Text(book.isPast ? 'Past meeting' : 'Upcoming meeting'),
        ),
        ListTile(
          leading: Icon(book.isOnline ? Icons.link : Icons.place),
          title: Text(book.place),
          subtitle: Text(
            book.isOnline ? 'Online meeting link' : 'Meeting place',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.library_books),
          title: Text('$taken borrowed · $free free'),
          subtitle: Text('${book.copies} copies in total'),
        ),
        if (book.notes case final notes?)
          ListTile(leading: const Icon(Icons.notes), title: Text(notes)),
      ],
    );
  }
}

class _ReadersTab extends StatelessWidget {
  const _ReadersTab({required this.book, required this.userName});

  final Book book;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final readers = book.readers;
    if (readers.isEmpty) {
      return const EmptyState(
        icon: Icons.person_off,
        message: 'Nobody has borrowed this book yet',
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final name in readers)
          ListTile(
            selected: name == userName,
            leading: CircleAvatar(child: Text(name.characters.first)),
            title: Text(name == userName ? '$name (You)' : name),
          ),
      ],
    );
  }
}
