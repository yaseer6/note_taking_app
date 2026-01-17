import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../widgets/notes_list.dart';

class SelectNotesPage extends StatefulWidget {
  const SelectNotesPage({super.key});

  @override
  State<SelectNotesPage> createState() => _SelectNotesPageState();
}

class _SelectNotesPageState extends State<SelectNotesPage> {
  final ValueNotifier<int> _refreshNotes = ValueNotifier(0);
  final List<String> _originalSelectedNoteIds = [];
  final List<String> _currentSelectedNoteIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if(args != null && args is List<String>) {
      _originalSelectedNoteIds.addAll(args);
      _currentSelectedNoteIds.addAll(args);
    }
  }

  bool _isSelectionModified() {
    return !listEquals(_originalSelectedNoteIds, _currentSelectedNoteIds);
  }

  void _popWithResult() {
    if(_isSelectionModified()) {
      Navigator.pop(context, _currentSelectedNoteIds);
    } else {
      Navigator.pop(context, null);
    }
  }

  @override
  void dispose() {
    _refreshNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentSelectedNoteIds.isEmpty
            ? 'Select Note'
            : '${_currentSelectedNoteIds.length} Selected',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _popWithResult,
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, Object? result) {
          if(didPop) return;
          _popWithResult();
        },
        child: Column(
          children: [
            const Divider(
              thickness: 2,
              color: Color.fromRGBO(0, 0, 0, 0.08),
            ),
            Expanded(
              child: NotesList(
                refreshNotifier: _refreshNotes,
                fromPage: AppRoutes.selectNotes,
                selectedNoteIds: _currentSelectedNoteIds,
                onNoteSelected: (noteId) {
                  setState(() {
                    if(_currentSelectedNoteIds.contains(noteId)) {
                      _currentSelectedNoteIds.remove(noteId);
                    } else {
                      _currentSelectedNoteIds.add(noteId);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
