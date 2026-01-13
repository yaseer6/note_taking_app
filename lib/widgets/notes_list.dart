import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'note_card.dart';
import 'package:note_taking_app/services/note_storage_service.dart';

class NotesList extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  final String fromPage;

  const NotesList({
    super.key,
    required this.refreshNotifier,
    required this.fromPage,
  });

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();

    widget.refreshNotifier.addListener(_handleRefresh);
  }

  void _handleRefresh() {
    if(mounted) {
      setState(() {
        _loadNotes();
      });
    }
  }

  void _loadNotes() {
    _notesFuture = NoteService.readNotes();
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_handleRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: _notesFuture,
      builder: (context, snapshot) {

        if(!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.hasError) {
          return Text('Error : ${snapshot.error}');
        }

        final notes = snapshot.data!;

        if(notes.isEmpty) {
          return const Center(child: Text('No notes yet'),);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            crossAxisCount: 2,
            childAspectRatio: 0.9,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return NoteCard(
              note: notes[index],
              onRefresh: () {
                widget.refreshNotifier.value++;
              },
              fromPage: widget.fromPage,
            );
          },
        );
      },
    );
  }
}
