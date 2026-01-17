import 'package:flutter/material.dart';
import 'package:note_taking_app/services/folder_storage_service.dart';
import 'package:note_taking_app/services/note_storage_service.dart';
import 'package:note_taking_app/widgets/folders_list.dart';
import 'package:note_taking_app/widgets/notes_list.dart';
import '../core/routes.dart';
import 'package:note_taking_app/widgets/add_folder_dialog.dart';
import '../models/folder_model.dart';
import '../models/note_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _notesRefresh = ValueNotifier(0);
  final ValueNotifier<int> _foldersRefresh = ValueNotifier(0);
  late Future<List<Note>> _notesFuture;
  late Future<List<Folder>> _foldersFuture;
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadNotes();
    _notesRefresh.addListener(_loadNotes);
    _loadFolders();
    _foldersRefresh.addListener(_loadFolders);
  }
  
  void _loadNotes() {
    setState(() {
      _notesFuture = NoteService.readNotes();
    });
  }

  void _loadFolders() {
    setState(() {
      _foldersFuture = FolderService.readFolders();
    });
  }
  
  @override
  void dispose() {
    _notesRefresh.removeListener(_loadNotes);
    _foldersRefresh.removeListener(_loadFolders);
    _notesRefresh.dispose();
    _foldersRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black12,
            ),
            const SizedBox(height: 8),

            // Tab Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton('All Notes', 0),
                _buildTabButton('Folders', 1),
              ],
            ),

            // Content Section
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  FutureBuilder(
                    future: _notesFuture,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if(snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'),);
                      }

                      if(!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No notes yet'));
                      }

                      final notes = snapshot.data!;

                      return NotesList(
                        notes: notes,
                        fromPage: AppRoutes.home,
                        onRefresh: () {
                          _notesRefresh.value++;
                        },
                      );
                    },
                  ),
                  FutureBuilder(
                    future: _foldersFuture,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if(snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'),);
                      }

                      if(!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No folders found'));
                      }

                      final folders = snapshot.data!;

                      return FoldersList(
                        folders: folders,
                        onRefresh: () {
                          _foldersRefresh.value++;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        label: Text(_selectedTabIndex == 0 ? 'Add new note' : 'Add new folder'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
            radius: 25,
          ),
          const SizedBox(width: 16),
          Text(
            'Floyd Lawton',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          //search button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
            iconSize: 28,
          ),
          //menu button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return TextButton(
      onPressed: () => setState(() => _selectedTabIndex = index),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.black : Colors.grey,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _onFabPressed() async {
    if (_selectedTabIndex == 0) {
      final result = await Navigator.pushNamed(context, AppRoutes.addEditNote);

      if(result == true && context.mounted) {
        _notesRefresh.value++;
      }
    } else {
      final bool folderWasCreated = await showAddFolderDialog(context);

      if(folderWasCreated) {
        _foldersRefresh.value++;
      }
    }
  }
}
