import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_taking_app/models/note_model.dart';
import 'package:note_taking_app/services/note_storage_service.dart';

class AddEditNotePage extends StatefulWidget {
  const AddEditNotePage({super.key});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _existingNote;
  List<String> _currentTags = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if(args is Note && _existingNote == null) {
      _existingNote = args;
      _titleController.text = _existingNote!.title;
      _contentController.text = _existingNote!.content;
      _currentTags = List.from(_existingNote!.tags);
    }
  }

  void _showTagMenu(
      BuildContext context,
      Offset position,
      int index,
      ) async {
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
          _existingNote == null? 'Add Note' : 'Edit Note',
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
            onSelected: (value) async {
              switch(value) {
                case 'save':
                  if(_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
                    Navigator.pop(context);
                    return;
                  }

                  final noteToSave = Note(
                    id: _existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    tags: _currentTags,
                    createdAt: DateTime.now(),
                  );

                  if(_existingNote == null) {
                    await NoteService.addNote(noteToSave);
                  } else {
                    await NoteService.updateNote(noteToSave);
                  }

                  if(context.mounted) Navigator.pop(context, true);
                  break;
                case 'delete':
                  if(_existingNote == null) return;
                  await NoteService.deleteNote(_existingNote!.id);
                  if(!context.mounted) return;
                  Navigator.pop(context, true);
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'save',
                child: Text(_existingNote == null? 'Save' : 'Update'),
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
              Table(
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
                          'Last Modified',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(_existingNote?.createdAt ?? DateTime.now()),
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
                              onPressed: () {
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
                                            if(tagController.text != '') {
                                              _currentTags.add(tagController.text);
                                              Navigator.pop(context);
                                              setState(() {});
                                            } else {
                                              Navigator.pop(context);
                                            }
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
                              },
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
                                onLongPressStart: (details) {
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
              ),
              const SizedBox(height: 8,),
              const Divider(
                thickness: 2,
                color: Color.fromRGBO(0, 0, 0, 0.08),
              ),
              const SizedBox(height: 16,),
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
}
