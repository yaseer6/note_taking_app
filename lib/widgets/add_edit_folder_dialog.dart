import 'package:flutter/material.dart';
import 'package:note_taking_app/data/folder_icons.dart';
import 'package:note_taking_app/models/folder_model.dart';
import 'package:note_taking_app/services/folder_storage_service.dart';

Future<bool> showAddFolderDialog(BuildContext context) async {
  // This will track if a folder was actually created
  bool folderCreated = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      final folderNameController = TextEditingController();
      int? selectedIconCode;
      int selectedIconIndex = -1; // -1 indicates no selection initially

      return StatefulBuilder(
        builder: (context, setState) =>
          AlertDialog(
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
                  decoration: const InputDecoration(hintText: 'Type here...'),
                ),
              ],
            ),
            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                ),
              ),
              //save button
              TextButton(
                onPressed: () async {
                  if (folderNameController.text.trim().isEmpty) {
                    Navigator.pop(dialogContext);
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

                  folderCreated = true; // Mark that a folder was created
                  if (context.mounted) Navigator.pop(dialogContext);
                },
                child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
      );
    },
  );

  return folderCreated;
}