import 'dart:io';
import 'dart:convert';
import 'package:note_taking_app/models/folder_model.dart';
import 'package:path_provider/path_provider.dart';


class FolderService {
  static List<Folder>? _cachedFolders;
  static File? _cachedFile;

  static Future<File> _getFile() async {
    if (_cachedFile != null) return _cachedFile!;

    final dir = await getApplicationDocumentsDirectory();
    _cachedFile = File('${dir.path}/folders.json');
    return _cachedFile!;
  }

  static Future<List<Folder>> readFolders() async {
    if (_cachedFolders != null) return List.from(_cachedFolders!);

    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedJson = jsonDecode(jsonString); //List<Map<String, dynamic>>
      _cachedFolders = decodedJson.map((e) => Folder.fromJson(e)).toList(); //List<Folder>
      return List.from(_cachedFolders!);
    } catch (e) {
      return [];
    }
  }

  static Future<void> createFolder(Folder folder) async {
    final folders = await readFolders();
    folders.add(folder);
    await _writeFolders(folders);
  }

  static Future<void> deleteFolder(String id) async {
    final folders = await readFolders();
    folders.removeWhere((folder) => folder.id == id);
    await _writeFolders(folders);
  }

  static Future<void> updateFolder(Folder updatedFolder) async {
    final folders = await readFolders();
    final index = folders.indexWhere((folder) => folder.id == updatedFolder.id);
    if (index != -1) {
      folders[index] = updatedFolder;
      await _writeFolders(folders);
    }
  }

  static Future<void> _writeFolders(List<Folder> folders) async {
    _cachedFolders = List.from(folders);
    final file = await _getFile();
    final encoded = jsonEncode(folders.map((e) => e.toJson()).toList());
    await file.writeAsString(encoded); // Added await here
  }
}
