import 'package:flutter/material.dart';
import 'package:note_taking_app/pages/add_edit_note_page.dart';
import 'package:note_taking_app/pages/folder_details_page.dart';
import 'package:note_taking_app/pages/home_page.dart';
import 'package:note_taking_app/pages/select_notes_page.dart';

import '../models/folder_model.dart';
import '../models/note_model.dart';

class AppRouter {
  static const String home = '/';
  static const String addEditNote = '/add-edit-note';
  static const String folderDetails = '/folder-details';
  static const String selectNotes = '/select-notes';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomePage());
      case addEditNote:
        final args = settings.arguments as Note?;
        return MaterialPageRoute(builder: (context) => AddEditNotePage(note: args));
      case folderDetails:
        final args = settings.arguments as Folder;
        return MaterialPageRoute(builder: (context) => FolderDetailsPage(folder: args));
      case selectNotes:
        final args = settings.arguments as List<String>;
        return MaterialPageRoute(builder: (context) => SelectNotesPage(notesIds: args));
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
