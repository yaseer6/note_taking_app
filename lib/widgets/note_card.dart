import 'package:flutter/material.dart';
import 'package:note_taking_app/core/routes.dart';
import '../models/note_model.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onRefresh;
  final String fromPage;

  const NoteCard({
    super.key,
    required this.note,
    required this.onRefresh,
    required this.fromPage,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        switch(widget.fromPage) {
          case AppRoutes.home:
            final didUpdate = await Navigator.pushNamed(
              context,
              AppRoutes.addEditNote,
              arguments: widget.note,
            );

            if(didUpdate == true) {
              widget.onRefresh();
            }
            break;
          case AppRoutes.selectNotes:
            isSelected = isSelected? false : true;
            if(isSelected) {

            }
            setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected? Color.fromRGBO(0, 0, 0, 0.2): Color.fromRGBO(0, 0, 0, 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //displays date
            Text(
              _formatDate(widget.note.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            //displays title
            Text(
              widget.note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            //displays tags
            if(widget.note.tags.isNotEmpty)
              SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.note.tags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Chip(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: isSelected? Color.fromRGBO(0, 0, 0, 0.2): Color.fromRGBO(0, 0, 0, 0.1),
                      side: BorderSide.none,
                      label: Text(
                        widget.note.tags[index],
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
                widget.note.content,
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

  String _formatDate(DateTime date) {
    return '${date.day} ${DateFormat.MMM().format(date)}';
  }
}
