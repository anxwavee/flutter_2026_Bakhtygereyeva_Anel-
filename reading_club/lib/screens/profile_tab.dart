import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.books,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Book> books;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Z]{2,5}-\d{2,4}$');

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _groupController = TextEditingController(
    text: widget.profile.group,
  );

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != _nameController.text) {
      _nameController.text = widget.profile.name;
    }
    if (widget.profile.group != _groupController.text) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your name';
    return null;
  }

  String? _validateGroup(String? value) {
    final group = value?.trim() ?? '';
    if (group.isEmpty) return null; // the group is optional
    if (!_groupPattern.hasMatch(group)) return 'Use the form IS-2301';
    return null;
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onProfileChanged(
      Profile(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    final listCount = widget.books.fold<int>(
      0,
      (count, book) => book.contains(name) ? count + 1 : count,
    );
    final hasUpcoming = widget.books.any(
      (book) => book.contains(name) && !book.isPast,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Group',
                  helperText: 'For example IS-2301. Press Enter to save.',
                  prefixIcon: Icon(Icons.groups),
                  border: OutlineInputBorder(),
                ),
                validator: _validateGroup,
                onFieldSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text('You are on $listCount lists'),
            subtitle: Text(
              name.isEmpty
                  ? 'Set your name to borrow books'
                  : hasUpcoming
                  ? 'You have an upcoming meeting'
                  : 'No upcoming meetings',
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_themeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
