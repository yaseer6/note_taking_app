import 'package:flutter/material.dart';
import '../models/folder_model.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
