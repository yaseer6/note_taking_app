import 'package:flutter/material.dart';
import 'package:note_taking_app/widgets/notes_list.dart';
import '../core/app_router.dart';
import '../models/note_model.dart';

class SearchPage extends StatefulWidget {
  final Future<List<Note>> notesFuture;
  const SearchPage({
    super.key,
    required this.notesFuture,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  late List<Note> allNotes;
  List<Note> filteredNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    widget.notesFuture.then((notes) {
      setState(() {
        allNotes = notes;
        filteredNotes = notes;
        isLoading = false;
      });
    });

    _searchController.addListener(onSearch);
  }

  void onSearch() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredNotes = allNotes.where((note) {
        return note.title.toLowerCase().contains(query) || note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(onSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Notes...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _searchController.clear(),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
        child: Column(
          children: [
            const Divider(
              thickness: 2,
              color: Color.fromRGBO(0, 0, 0, 0.08),
              indent: 16,
              endIndent: 16,
            ),
            Expanded(
              child: NotesList(
                notes: filteredNotes,
                fromPage: AppRouter.searchNotes,
                onRefresh: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
