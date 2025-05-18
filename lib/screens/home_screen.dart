import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notification_demo/services/firestore.dart';
import 'package:notification_demo/widgets/note_card.dart';
import 'package:notification_demo/widgets/note_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firestoreService = FirestoreService();
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void openNoteBox({String? docID, String? existingText}) {
    showDialog(
      context: context,
      builder: (context) => NoteDialog(
        docID: docID,
        existingText: existingText,
        formKey: formKey,
        textController: textController,
      ),
    ).then((_) => textController.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notes yet!'));
          }

          final notesList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              return NoteTile(
                document: notesList[index],
                onEdit: (docID, text) =>
                    openNoteBox(docID: docID, existingText: text),
              );
            },
          );
        },
      ),
    );
  }
}
