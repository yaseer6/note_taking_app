import 'package:flutter/material.dart';
import 'package:note_taking_app/data/folder_icons.dart';
import 'package:note_taking_app/models/folder_model.dart';
import 'package:note_taking_app/services/folder_storage_service.dart';
import 'package:note_taking_app/widgets/folders_list.dart';
import 'package:note_taking_app/widgets/notes_list.dart';
import '../core/routes.dart';

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
      _showAddFolderDialog();
    }
  }

  void _showAddFolderDialog() {
    int? selectedIconCode;
    int selectedIconIndex = -1; // -1 indicates no selection initially

    showDialog(
      context: context,
      builder: (context) {
        final folderNameController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Create Folder'),
            titleTextStyle: Theme.of(context).textTheme.titleLarge,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select icon: '),
                    SizedBox(
                      height: 40,
                      width: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: folderIcons.length,
                        itemBuilder: (context, index) {
                          final icon = folderIcons[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            child: FilterChip(
                              label: Icon(icon),
                              selected: selectedIconIndex == index,
                              onSelected: (isSelected) {
                                // Update the state within the dialog
                                setState(() {
                                  if (isSelected) {
                                    selectedIconIndex = index;
                                    selectedIconCode = icon.codePoint;
                                  } else {
                                    // Optional: Allow deselection
                                    selectedIconIndex = -1;
                                    selectedIconCode = null;
                                  }
                                });
                              },
                              selectedColor: Colors.grey.shade300,
                              showCheckmark: false,
                            ),
                          );
                      }),
                    )
                  ],
                ),
                TextField(
                  controller: folderNameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: 'Type here...'
                  ),
                ),
              ],
            ),
            actions: [
              //cancel button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              //save button
              TextButton(
                onPressed: () async {
                  if(folderNameController.text.trim().isEmpty) {
                    Navigator.pop(context);
                    return;
                  }

                  final folder = Folder(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: folderNameController.text,
                    iconCode: selectedIconCode ?? Icons.folder.codePoint,
                    noteIds: [],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await FolderService.createFolder(folder);

                  if(context.mounted) Navigator.pop(context);

                  _foldersRefresh.value++;
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
