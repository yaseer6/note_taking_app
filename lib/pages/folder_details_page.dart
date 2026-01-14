import 'package:flutter/material.dart';
import 'package:note_taking_app/data/folder_icons.dart';
import 'package:note_taking_app/models/folder_model.dart';
import 'package:note_taking_app/services/folder_storage_service.dart';
import 'package:intl/intl.dart';
import 'package:note_taking_app/widgets/notes_list.dart';
import '../core/routes.dart';

class FolderDetailsPage extends StatefulWidget {
  const FolderDetailsPage({super.key});

  @override
  State<FolderDetailsPage> createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  final ValueNotifier<int> _refreshNotes = ValueNotifier(0);
  final _titleController = TextEditingController();
  Folder? folder;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Folder;

    if(folder == null) {
      folder = args;
      _titleController.text = folder!.name;
    }
  }

  void _save(BuildContext context) async {
    if(_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 700),
          content: Text('Title cannot be empty!'),
        ),
      );
      return;
    }

    final updatedFolder = Folder(
      id: folder!.id,
      name: _titleController.text,
      iconCode: folder!.iconCode,
      noteIds: folder!.noteIds,
      createdAt: folder!.createdAt,
      updatedAt: DateTime.now(),
    );

    await FolderService.updateFolder(updatedFolder);

    if(context.mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz),
            iconSize: 28,
            onSelected: (value) async {
              switch(value) {
                case 'save':
                  _save(context);
                  break;
                case 'delete':
                  await FolderService.deleteFolder(folder!.id);
                  if(context.mounted) Navigator.pop(context, true);
                  break;
                case 'addNote':
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.selectNotes,
                    arguments: folder!.noteIds,
                  );

                  if(result != null && result is List<String> && result.isNotEmpty) {
                    folder!.noteIds = result;
                  }
                  _refreshNotes.value++;
                  break;
              }
            },
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'save',
                child: Text('Save'),
              ),
              PopupMenuItem<String>(
                value: 'addNote',
                child: Text('Add Note'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, Object? result) {
          if(didPop) return;
          _save(context);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
          child: Column(
            children: [
              Padding(
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
                    Row(
                      children: [
                        // const SizedBox(width: 8,),
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'title..',
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                            ),
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final iconCode = await showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return GridView.builder(
                                  padding: EdgeInsets.all(16),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                                  itemCount: folderIcons.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context, folderIcons[index].codePoint);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(0, 0, 0, 0.06),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(IconData(folderIcons[index].codePoint, fontFamily: 'MaterialIcons')),
                                      ),
                                    );
                                  },
                                );
                              },
                            );

                            if(iconCode != null) {
                              folder!.iconCode = iconCode;
                            }
                          },
                          icon: Icon(IconData(folder!.iconCode, fontFamily: 'MaterialIcons')),
                          iconSize: 28,
                          tooltip: "Change icon",
                        ),
                      ],
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
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
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
                                DateFormat('dd MMM yyyy, hh:mm a').format(folder!.createdAt),
                              ),
                            ),
                          ],
                        ),
                        //updatedAt
                        TableRow(
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
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
                                DateFormat('dd MMM yyyy, hh:mm a').format(folder!.updatedAt),
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
                  ],
                ),
              ),
              Expanded(
                child: NotesList(
                  refreshNotifier: _refreshNotes,
                  fromPage: AppRoutes.folderDetails,
                  selectedNoteIds: folder!.noteIds,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
