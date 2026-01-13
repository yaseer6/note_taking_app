import 'package:flutter/material.dart';
import 'package:note_taking_app/pages/folder_details_page.dart';
import 'package:note_taking_app/pages/home_page.dart';
import 'package:note_taking_app/pages/add_edit_note_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_taking_app/pages/select_notes_page.dart';
import 'core/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.addEditNote: (context) => const AddEditNotePage(),
        AppRoutes.folderDetails: (context) => const FolderDetailsPage(),
        AppRoutes.selectNotes: (context) => const SelectNotesPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: GoogleFonts.poppinsTextTheme(),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
