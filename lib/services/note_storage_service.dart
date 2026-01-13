import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

class NoteService {
  static List<Note>? _cachedNotes;
  static File? _cachedFile;

  static Future<File> _getFile() async {
    if (_cachedFile != null) return _cachedFile!;

    final dir = await getApplicationDocumentsDirectory();
    _cachedFile = File('${dir.path}/notes.json');
    return _cachedFile!;
  }

  static Future<List<Note>> readNotes() async {
    if (_cachedNotes != null) return List.from(_cachedNotes!);

    try {
      final file = await _getFile();
      if (!await file.exists()) return [];

      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) return [];

      final List<dynamic> decodedJson = jsonDecode(jsonString);
      _cachedNotes = decodedJson.map((e) => Note.fromJson(e)).toList();
      return List.from(_cachedNotes!);
    } catch (e) {
      return [];
    }
  }

  static Future<void> addNote(Note note) async {
    final notes = await readNotes();
    notes.add(note);
    await _writeNotes(notes);
  }

  static Future<void> deleteNote(String id) async {
    final notes = await readNotes();
    notes.removeWhere((note) => note.id == id);
    await _writeNotes(notes);
  }

  static Future<void> updateNote(Note updatedNote) async {
    final notes = await readNotes();
    final index = notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      notes[index] = updatedNote;
      await _writeNotes(notes);
    }
  }

  static Future<void> _writeNotes(List<Note> notes) async {
    _cachedNotes = List.from(notes);
    final file = await _getFile();
    final encoded = jsonEncode(notes.map((e) => e.toJson()).toList());
    await file.writeAsString(encoded); // Added await here
  }
}
