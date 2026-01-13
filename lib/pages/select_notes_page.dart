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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Note'),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        actions: const [
          Icon(Icons.search),
        ],
      ),
      body: Column(
        children: [
          const Divider(
            thickness: 2,
            color: Color.fromRGBO(0, 0, 0, 0.08),
          ),
          Expanded(
            child: NotesList(
              refreshNotifier: _refreshNotes,
              fromPage: AppRoutes.selectNotes,
            ),
          ),
        ],
      ),
    );
  }
}
