import 'package:flutter/material.dart';
import 'package:reading_club/models/book.dart';
import 'package:reading_club/models/genre.dart';
import 'package:reading_club/utils/format.dart';

class FormArgs {
  const FormArgs({this.book});

  final Book? book;
}

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _copiesController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _copiesFocus = FocusNode();
  final _notesFocus = FocusNode();

  late final Book _initial = widget.book ?? Book.empty();

  BookGenre? _genre;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isOnline = false;
  bool _dirty = false;
  bool _saving = false;

  bool get _isNew => widget.book == null;

  @override
  void initState() {
    super.initState();
    _titleController.text = _initial.title;
    _placeController.text = _initial.place;
    _copiesController.text = '${_initial.copies}';
    _notesController.text = _initial.notes ?? '';
    _isOnline = _initial.isOnline;
    // A new book starts with no genre, date or time: the user must pick them
    if (widget.book case final book?) {
      _genre = book.genre;
      _date = book.meetingAt;
      _time = TimeOfDay.fromDateTime(book.meetingAt);
      _dateController.text = formatDate(book.meetingAt);
      _timeController.text = formatTime(book.meetingAt);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _copiesController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _copiesFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  DateTime? get _meetingAt {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool get _hasChanges =>
      _titleController.text != _initial.title ||
      _placeController.text != _initial.place ||
      _copiesController.text != '${_initial.copies}' ||
      _notesController.text != (_initial.notes ?? '') ||
      _isOnline != _initial.isOnline ||
      _genre != widget.book?.genre ||
      _meetingAt != widget.book?.meetingAt;

  void _updateDirty() {
    final dirty = _hasChanges;
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  // ---------- validators ----------

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.length < 3) return 'At least 3 characters';
    if (title.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final place = value?.trim() ?? '';
    if (place.isEmpty) {
      return _isOnline ? 'Enter a meeting link' : 'Enter a place';
    }
    if (_isOnline && !place.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateCopies(String? value) {
    final copies = int.tryParse(value?.trim() ?? '');
    if (copies == null) return 'Enter a whole number';
    if (copies < 1 || copies > 500) return 'From 1 to 500';
    if (copies < _initial.readerCount) {
      return '${_initial.readerCount} readers already have a copy';
    }
    return null;
  }

  String? _validateGenre(BookGenre? value) =>
      value == null ? 'Choose a genre' : null;

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    if (_time == null) return 'Pick a time';
    final meetingAt = _meetingAt;
    if (_isNew && meetingAt != null && meetingAt.isBefore(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  // ---------- pickers ----------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: _isNew ? today : DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    if (!mounted) return;
    _dateController.text = formatDate(picked);
    setState(() => _date = picked);
    _updateDirty();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null) return;
    if (!mounted) return;
    _timeController.text = formatClock(picked.hour, picked.minute);
    setState(() => _time = picked);
    _updateDirty();
  }

  // ---------- save and leave ----------

  Future<void> _save() async {
    if (_saving) return;
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final notes = _notesController.text.trim();
    final book = Book(
      id: _isNew
          ? 'book-${DateTime.now().microsecondsSinceEpoch}'
          : _initial.id,
      title: _titleController.text.trim(),
      genre: _genre ?? _initial.genre,
      meetingAt: _meetingAt ?? _initial.meetingAt,
      place: _placeController.text.trim(),
      copies: int.parse(_copiesController.text.trim()),
      readers: _initial.readers,
      isOnline: _isOnline,
      notes: notes.isEmpty ? null : notes,
      isFavourite: _initial.isFavourite,
    );
    Navigator.pop(context, book);
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes to this book will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _handleBlockedPop() async {
    final discard = await _confirmDiscard();
    if (!discard) return;
    if (!mounted) return;
    Navigator.pop(context);
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return PopScope<Book>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBlockedPop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New book' : 'Edit book')),
        body: Form(
          key: _formKey,
          onChanged: _updateDirty,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BookGenre>(
                initialValue: _genre,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final genre in BookGenre.values)
                    DropdownMenuItem(
                      value: genre,
                      child: Row(
                        children: [
                          Icon(genre.icon),
                          const SizedBox(width: 8),
                          Text(genre.label),
                        ],
                      ),
                    ),
                ],
                validator: _validateGenre,
                onChanged: (value) {
                  setState(() => _genre = value);
                  _updateDirty();
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online meeting'),
                subtitle: const Text('The place becomes a link'),
                value: _isOnline,
                onChanged: (value) {
                  setState(() => _isOnline = value ?? false);
                  _updateDirty();
                },
              ),
              TextFormField(
                controller: _placeController,
                focusNode: _placeFocus,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: _isOnline
                    ? TextInputType.url
                    : TextInputType.text,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (_) => _copiesFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: _isOnline ? 'Meeting link' : 'Place',
                  hintText: _isOnline ? 'https://…' : 'Library, room 204',
                  prefixIcon: Icon(_isOnline ? Icons.link : Icons.place),
                  border: const OutlineInputBorder(),
                ),
                validator: _validatePlace,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.event),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _copiesController,
                focusNode: _copiesFocus,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (_) => _notesFocus.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'Copies',
                  helperText: 'How many copies the club has (1–500)',
                  prefixIcon: Icon(Icons.library_books),
                  border: OutlineInputBorder(),
                ),
                validator: _validateCopies,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                focusNode: _notesFocus,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
