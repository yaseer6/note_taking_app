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
  final List<String> _selectedNoteIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if(args != null && args is List<String>) {
      _selectedNoteIds.addAll(args);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Note'),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedNoteIds);
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, Object? result) {
          if(didPop) return;
          Navigator.pop(context, _selectedNoteIds);
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
                selectedNoteIds: _selectedNoteIds,
                onNoteSelected: (noteId) {
                  setState(() {
                    if(_selectedNoteIds.contains(noteId)) {
                      _selectedNoteIds.remove(noteId);
                    } else {
                      _selectedNoteIds.add(noteId);
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
