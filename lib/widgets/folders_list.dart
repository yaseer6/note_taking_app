import 'package:flutter/material.dart';
import '../models/folder_model.dart';
import '../services/folder_storage_service.dart';
import 'folder_card.dart';

class FoldersList extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;

  const FoldersList({
    super.key,
    required this.refreshNotifier,
  });

  @override
  State<FoldersList> createState() => _FoldersListState();
}

class _FoldersListState extends State<FoldersList> {
  Future<List<Folder>>? _foldersFuture;

  @override
  void initState() {
    super.initState();
   _loadFolders();

   widget.refreshNotifier.addListener(_handleRefresh);
  }

  void _handleRefresh() {
    if(mounted) {
      setState(() {
        _loadFolders();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadFolders();
  }

  void _loadFolders() {
    _foldersFuture = FolderService.readFolders();
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_handleRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _foldersFuture,
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final folders = snapshot.data!;

        if(folders.isEmpty) {
          return const Center(
            child: Text(
              'No folders found'
            ),
          );
        }

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
              onRefresh: () => widget.refreshNotifier.value++,
            );
          },
        );
      }
    );
  }
}
