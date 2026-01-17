import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:note_taking_app/data/folder_icons.dart';
import 'package:note_taking_app/models/folder_model.dart';
import 'package:note_taking_app/services/folder_storage_service.dart';
import 'package:intl/intl.dart';
import 'package:note_taking_app/services/note_storage_service.dart';
import 'package:note_taking_app/widgets/notes_list.dart';
import '../core/routes.dart';
import '../models/note_model.dart';

class FolderDetailsPage extends StatefulWidget {
  const FolderDetailsPage({super.key});

  @override
  State<FolderDetailsPage> createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  final ValueNotifier<int> _refreshNotes = ValueNotifier(0);
  final _titleController = TextEditingController();
  late int _currentIconCode;
  late List<String> _currentNoteIds;
  Folder? _originalFolder;
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _refreshNotes.addListener(_loadNotes);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if(_originalFolder == null) {
      final args = ModalRoute.of(context)!.settings.arguments as Folder;

      _originalFolder = args;
      _titleController.text = _originalFolder!.name;

      _currentIconCode = _originalFolder!.iconCode;
      _currentNoteIds = List<String>.from(_originalFolder!.noteIds);
    }
  }

  void _loadNotes() {
    setState(() {
      _notesFuture = NoteService.readNotes();
    });
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

    if(!_isFolderModified()) {
      Navigator.pop(context, false);
      return;
    }

    final updatedFolder = _originalFolder!.copyWith(
      name: _titleController.text,
      iconCode: _currentIconCode,
      noteIds: _currentNoteIds,
      updatedAt: DateTime.now(),
    );

    await FolderService.updateFolder(updatedFolder);

    if(context.mounted) Navigator.pop(context, true);
  }

  bool _isFolderModified() {
    final bool nameChanged = _originalFolder!.name != _titleController.text;
    final bool iconChanged = _originalFolder!.iconCode != _currentIconCode;
    final bool notesChanged = !listEquals(_originalFolder!.noteIds, _currentNoteIds);

    return nameChanged || iconChanged || notesChanged;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _refreshNotes.removeListener(_loadNotes);
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
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'save',
                child: Text('Save'),
              ),
              PopupMenuItem<String>(
                value: 'addRemoveNote',
                child: Text('Add/Remove Note'),
              ),
              PopupMenuItem<String>(
                value: 'deleteFolder',
                child: Text('Delete Folder'),
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
                    _buildTitleEditor(),
                    const SizedBox(height: 12,),
                    _buildMetadataTable(),
                    const SizedBox(height: 8,),
                    const Divider(
                      thickness: 2,
                      color: Color.fromRGBO(0, 0, 0, 0.08),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Note>>(
                  future: _notesFuture,
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(),);
                    }

                    if(snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'),);
                    }

                    if(!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No notes yet'));
                    }

                    final allNotes = snapshot.data!;

                    //filtering for the specific folder
                    final Set<String> folderNoteIds = _currentNoteIds.toSet();

                    final List<Note> notesForThisFolder = allNotes.where((note) => folderNoteIds.contains(note.id)).toList();

                    return NotesList(
                      notes: notesForThisFolder,
                      onRefresh: () {
                        _refreshNotes.value++;
                      },
                      fromPage: AppRoutes.folderDetails,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuSelection(String value) async {
    switch(value) {
      case 'save':
        _save(context);
        break;
      case 'deleteFolder':
        await FolderService.deleteFolder(_originalFolder!.id);
        if(mounted) Navigator.pop(context, true);
        break;
      case 'addRemoveNote':
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.selectNotes,
          arguments: _currentNoteIds,
        );

        if(result != null && result is List<String>) {
          setState(() {
            _currentNoteIds = result;
          });
          _refreshNotes.value++;
        }
        break;
    }
  }

  Widget _buildTitleEditor() {
    return Row(
      children: [
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
          onPressed: _showIconPicker,
          icon: Icon(IconData(_currentIconCode, fontFamily: 'MaterialIcons')),
          iconSize: 28,
          tooltip: "Change icon",
        ),
      ],
    );
  }

  Future<void> _showIconPicker() async {
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
      setState(() {
        _currentIconCode = iconCode;
      });
    }
  }

  Widget _buildMetadataTable() {
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
                DateFormat('dd MMM yyyy, hh:mm a').format(_originalFolder!.createdAt),
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
                DateFormat('dd MMM yyyy, hh:mm a').format(_originalFolder!.updatedAt),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
