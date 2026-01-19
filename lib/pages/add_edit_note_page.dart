import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_taking_app/models/note_model.dart';
import 'package:note_taking_app/services/note_storage_service.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;
  const AddEditNotePage({
    super.key,
    required this.note,
  });

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _originalNote;
  List<String> _currentTags = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if(widget.note is Note && _originalNote == null) {
      _originalNote = widget.note;
      _titleController.text = _originalNote!.title;
      _contentController.text = _originalNote!.content;
      _currentTags = List.from(_originalNote!.tags);
    }
  }

  void _save(BuildContext context) async {
    if(_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    if(!_isNoteModified()) {
      Navigator.pop(context, false);
      return;
    }

    if(_originalNote == null) {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _currentTags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await NoteService.addNote(newNote);
    } else {
      final updatedNote = _originalNote!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _currentTags,
        updatedAt: DateTime.now(),
      );
      await NoteService.updateNote(updatedNote);
    }

    if(context.mounted) Navigator.pop(context, true);
  }

  bool _isNoteModified() {
    if(_originalNote == null) {
      return _titleController.text.trim().isNotEmpty || _contentController.text.trim().isNotEmpty;
    }

    final bool titleChanged = _originalNote!.title != _titleController.text.trim();
    final bool contentChanged = _originalNote!.content != _contentController.text.trim();
    final bool tagsChanged = !listEquals(_originalNote!.tags, _currentTags);

    return titleChanged || contentChanged || tagsChanged;
  }

  void _handleMenuSelection(String value) async {
    switch(value) {
      case 'save':
        _save(context);
        break;
      case 'delete':
        if(_originalNote == null) return;
        await NoteService.deleteNote(_originalNote!.id);
        if(mounted) Navigator.pop(context, true);
        break;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _originalNote == null? 'Add Note' : 'Edit Note',
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          color: Color.fromRGBO(0, 0, 0, 1),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            iconSize: 28,
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'save',
                child: Text(_originalNote == null? 'Save' : 'Update'),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: Text('Share'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                thickness: 2,
                color: Color.fromRGBO(0, 0, 0, 0.08),
              ),
              const SizedBox(height: 16,),
              //title text field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'title..',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none
                  ),
                ),
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12,),
              _buildDataTable(),
              const SizedBox(height: 8,),
              const Divider(
                thickness: 2,
                color: Color.fromRGBO(0, 0, 0, 0.08),
              ),
              const SizedBox(height: 16,),
              //content text area
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Type here...',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: <TableRow>[
        //createdAt
        TableRow(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Created At',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(_originalNote?.createdAt ?? DateTime.now()),
              ),
            ),
          ],
        ),
        TableRow(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Last Modified',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(_originalNote?.updatedAt ?? DateTime.now()),
              ),
            ),
          ],
        ),
        //tags
        TableRow(
          children: <Widget>[
            //add tags button
            Row(
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12,),
                SizedBox(
                  height: 25,
                  width: 25,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: _onAddTagPressed,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
                      foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
                    ),
                    icon: const Icon(Icons.add,),
                    iconSize: 18,
                  ),
                ),
              ],
            ),
            //displays tags
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _currentTags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                    child: GestureDetector(
                      onTapDown: (details) {
                        _showTagMenu(
                          context,
                          details.globalPosition,
                          index,
                        );
                      },
                      child: Chip(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.06),
                        side: BorderSide.none,
                        label: Text(
                          _currentTags[index],
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTagMenu(BuildContext context, Offset position, int index) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );

    if (selected == 'delete') {
      setState(() {
        _currentTags.removeAt(index);
      });
    }

    if (selected == 'edit') {
      _editTag(index);
    }
  }

  void _editTag(int index) {
    final controller = TextEditingController(
      text: _currentTags[index],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _currentTags[index] = controller.text.trim();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onAddTagPressed() {
    final tagController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'Enter tag'
            ),
            content: TextField(
              controller: tagController,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: 'Type here...'
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if(tagController.text.trim().isNotEmpty) {
                    setState(() {
                      if(!_currentTags.contains(tagController.text.trim())) {
                        _currentTags.add(tagController.text.trim());
                      }
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
}
