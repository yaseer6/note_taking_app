import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

class NoteService {
  static List<Note>? _cachedNotes;
  static File? _cachedFile;

  static bool _isInitialized = false;

  static Future<File> _getFile() async {
    if (_cachedFile != null) return _cachedFile!;

    final dir = await getApplicationDocumentsDirectory();
    _cachedFile = File('${dir.path}/notes.json');
    return _cachedFile!;
  }

  static Future<void> _ensureInitialized() async {
    if(_isInitialized) return;

    try {
      final file = await _getFile();

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        if(jsonString.isNotEmpty) {
          final List<dynamic> decodedJson = jsonDecode(jsonString);
          _cachedNotes = decodedJson.map((e) => Note.fromJson(e)).toList();
        } else {
          _cachedNotes = [];
        }
      } else {
        _cachedNotes = [];
      }

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize NoteService: $e');
      _cachedNotes = [];
      _isInitialized = true;
    }
  }

  static Future<List<Note>> readNotes() async {
    await _ensureInitialized();
    return List.from(_cachedNotes!);
  }

  static Future<void> addNote(Note note) async {
    await _ensureInitialized();
    _cachedNotes!.add(note);
    await _writeNotes();
  }

  static Future<void> deleteNote(String id) async {
    await _ensureInitialized();
    _cachedNotes!.removeWhere((note) => note.id == id);
    await _writeNotes();
  }

  static Future<void> updateNote(Note updatedNote) async {
    await _ensureInitialized();
    final index = _cachedNotes!.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _cachedNotes![index] = updatedNote;
      await _writeNotes();
    }
  }

  static Future<void> _writeNotes() async {
    if(_cachedNotes == null) return;

    final file = await _getFile();
    final encoded = jsonEncode(_cachedNotes!.map((e) => e.toJson()).toList());
    await file.writeAsString(encoded); // Added await here
  }
}
