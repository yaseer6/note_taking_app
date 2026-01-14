import 'package:flutter/material.dart';
import 'package:note_taking_app/core/routes.dart';
import '../models/folder_model.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback onRefresh;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final didUpdate = await Navigator.pushNamed(
          context,
          AppRoutes.folderDetails,
          arguments: folder,
        );

        if(didUpdate == true) {
          onRefresh();
        }
      },
      onLongPress: () {
        Navigator.pushNamed(context, AppRoutes.addEditNote);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconData(folder.iconCode, fontFamily: 'MaterialIcons'),
              size: 50,
            ),
            const SizedBox(height: 4,),
            Text(
              folder.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
