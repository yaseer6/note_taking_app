import 'package:flutter/material.dart';
import '../models/folder_model.dart';
import 'folder_card.dart';

class FoldersList extends StatelessWidget {
  final List<Folder> folders;
  final VoidCallback onRefresh;

  const FoldersList({
    super.key,
    required this.folders,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        crossAxisCount: 2,
        childAspectRatio: 0.9,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        return FolderCard(
          folder: folders[index],
          onRefresh: onRefresh,
        );
      },
    );
  }
}
