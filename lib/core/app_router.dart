import 'package:flutter/material.dart';
import 'package:note_taking_app/pages/add_edit_note_page.dart';
import 'package:note_taking_app/pages/folder_details_page.dart';
import 'package:note_taking_app/pages/home_page.dart';
import 'package:note_taking_app/pages/select_notes_page.dart';

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
        return MaterialPageRoute(builder: (context) => const AddEditNotePage());
      case folderDetails:
        return MaterialPageRoute(builder: (context) => const FolderDetailsPage());
      case selectNotes:
        return MaterialPageRoute(builder: (context) => const SelectNotesPage());
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
