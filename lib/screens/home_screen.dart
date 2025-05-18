import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:notification_demo/services/notification_service.dart';
import 'package:notification_demo/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void openNoteBox({String? docID, String? existingText}) {
    textController.text = existingText ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docID == null ? 'Add Note' : 'Update Note'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter your note here'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final text = textController.text.trim();
                Navigator.pop(context);

                // Add or update note
                if (docID == null) {
                  await firestoreService.addNote(text);
                  await NotificationService.createNotification(
                      id: 1,
                      title: 'Note added',
                      body: 'Your note is "' + text + '"',
                      summary: 'Your note has been successfully added<3');
                } else {
                  await firestoreService.updateNote(docID, text);
                  await NotificationService.createNotification(
                      id: 1,
                      title: 'Note updated',
                      body: 'The updated note is "' + text + '"',
                      summary: 'Your note has been successfully updated<3');
                }

                textController.clear();
              }
            },
            child: Text(docID == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    ).then((_) {
      textController.clear(); // Reset if user taps outside dialog
    });
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

          final List<DocumentSnapshot> notesList = snapshot.data!.docs;

          if (notesList.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }

          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = notesList[index];
              final String docID = document.id;
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String noteText = data['note'];

              return ListTile(
                title: Text(noteText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () =>
                          openNoteBox(docID: docID, existingText: noteText),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => firestoreService.deleteNote(docID),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
