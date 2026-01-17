import 'package:flutter/material.dart';
import 'package:note_taking_app/core/routes.dart';
import '../models/note_model.dart';
import 'note_card.dart';

class NotesList extends StatelessWidget {
  final List<Note> notes;
  final String fromPage;
  final VoidCallback onRefresh;
  final List<String>? selectedNoteIds;
  final Function(String)? onNoteSelected;

  const NotesList({
    super.key,
    required this.notes,
    required this.fromPage,
    required this.onRefresh,
    this.selectedNoteIds,
    this.onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
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
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () async {
            if(fromPage == AppRoutes.home || fromPage == AppRoutes.folderDetails) {
              final didUpdate = await Navigator.pushNamed(
                context,
                AppRoutes.addEditNote,
                arguments: note,
              );

              if(didUpdate == true) {
                onRefresh();
              }
            } else if(fromPage == AppRoutes.selectNotes) {
              onNoteSelected?.call(note.id);
            }
          },
          isSelected: selectedNoteIds?.contains(note.id) ?? false,
        );
      },
    );
  }
}
