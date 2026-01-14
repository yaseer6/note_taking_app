import 'package:flutter/material.dart';
import 'package:note_taking_app/widgets/folders_list.dart';
import 'package:note_taking_app/widgets/notes_list.dart';
import '../core/routes.dart';
import 'package:note_taking_app/widgets/add_edit_folder_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _notesRefresh = ValueNotifier(0);
  final ValueNotifier<int> _foldersRefresh = ValueNotifier(0);
  int _selectedList = 0;

  @override
  void dispose() {
    _notesRefresh.dispose(); // Critical for performance/memory
    _foldersRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
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
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black12,
            ),
            const SizedBox(height: 8),

            // Tab Selection Section
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
                index: _selectedList,
                children: [
                  NotesList(refreshNotifier: _notesRefresh, fromPage: AppRoutes.home),
                  FoldersList(refreshNotifier: _foldersRefresh),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        label: Text(_selectedList == 0 ? 'Add new note' : 'Add new folder'),
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

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedList == index;
    return TextButton(
      onPressed: () => setState(() => _selectedList = index),
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
    if (_selectedList == 0) {
      await Navigator.pushNamed(context, AppRoutes.addEditNote);
      _notesRefresh.value++;
    } else {
      final bool folderWasCreated = await showAddFolderDialog(context);

      if(folderWasCreated) {
        _foldersRefresh.value++;
      }
    }
  }
}
