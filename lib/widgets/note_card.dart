import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'package:note_taking_app/utils/formatters.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected? Colors.blue.withAlpha(77): const Color.fromRGBO(0, 0, 0, 0.06),
          borderRadius: BorderRadius.circular(12),
          border: isSelected? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //displays date
            Text(
              formatDateForCard(note.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            //displays title
            Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            //displays tags
            if(note.tags.isNotEmpty)
              SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: note.tags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Chip(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: isSelected? Colors.blue.withAlpha(77): const Color.fromRGBO(0, 0, 0, 0.1),
                      side: BorderSide.none,
                      label: Text(
                        note.tags[index],
                      ),
                      labelStyle: const TextStyle(
                          fontSize: 12
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6,),
            //displays content
            Expanded(
              child: Text(
                note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
