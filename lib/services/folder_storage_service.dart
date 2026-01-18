import 'dart:io';
import 'dart:convert';
import 'package:note_taking_app/models/folder_model.dart';
import 'package:path_provider/path_provider.dart';


class FolderService {
  static List<Folder>? _cachedFolders;
  static File? _cachedFile;

  static bool _isInitialized = false;

  static Future<File> _getFile() async {
    if (_cachedFile != null) return _cachedFile!;

    final dir = await getApplicationDocumentsDirectory();
    _cachedFile = File('${dir.path}/folders.json');
    return _cachedFile!;
  }

  static Future<void> _ensureInitialized() async {
    if(_isInitialized) return;

    try {
      final file = await _getFile();

      if(await file.exists()) {
        final jsonString = await file.readAsString();
        if(jsonString.isNotEmpty) {
          final List<dynamic> decodedJson = jsonDecode(jsonString);
          _cachedFolders = decodedJson.map((e) => Folder.fromJson(e)).toList();
        } else {
          _cachedFolders = [];
        }
      } else {
        _cachedFolders = [];
      }
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize FolderService: $e');
      _cachedFolders = [];
      _isInitialized = true;
    }
  }

  static Future<List<Folder>> readFolders() async {
    await _ensureInitialized();
    return List.from(_cachedFolders!);
  }

  static Future<void> createFolder(Folder folder) async {
    await _ensureInitialized();
    _cachedFolders!.add(folder);
    await _writeFolders();
  }

  static Future<void> deleteFolder(String id) async {
    await _ensureInitialized();
    _cachedFolders!.removeWhere((folder) => folder.id == id);
    await _writeFolders();
  }

  static Future<void> updateFolder(Folder updatedFolder) async {
    await _ensureInitialized();
    final index = _cachedFolders!.indexWhere((folder) => folder.id == updatedFolder.id);
    if (index != -1) {
      _cachedFolders![index] = updatedFolder;
      await _writeFolders();
    }
  }

  static Future<void> _writeFolders() async {
    if(_cachedFolders == null) return;

    final file = await _getFile();
    final encoded = jsonEncode(_cachedFolders!.map((e) => e.toJson()).toList());
    await file.writeAsString(encoded); // Added await here
  }
}
