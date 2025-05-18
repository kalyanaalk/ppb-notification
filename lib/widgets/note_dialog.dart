import 'package:flutter/material.dart';
import 'package:notification_demo/services/firestore.dart';
import 'package:notification_demo/services/notification_service.dart';

class NoteDialog extends StatelessWidget {
  final String? docID;
  final String? existingText;
  final GlobalKey<FormState> formKey;
  final TextEditingController textController;

  const NoteDialog({
    Key? key,
    this.docID,
    this.existingText,
    required this.formKey,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    textController.text = existingText ?? '';
    final firestoreService = FirestoreService();

    return AlertDialog(
      title: Text(docID == null ? 'Add Note' : 'Update Note'),
      content: Form(
        key: formKey,
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
            if (formKey.currentState!.validate()) {
              final text = textController.text.trim();
              Navigator.pop(context);

              if (docID == null) {
                await firestoreService.addNote(text);
                await NotificationService.createNotification(
                  id: 1,
                  title: 'Note added',
                  body: 'Your note is "$text"',
                  summary: 'Added successfully <3',
                );
              } else {
                await firestoreService.updateNote(docID!, text);
                await NotificationService.createNotification(
                  id: 2,
                  title: 'Note updated',
                  body: 'Your updated note is "$text"',
                  summary: 'Updated successfully <3',
                );
              }

              textController.clear();
            }
          },
          child: Text(docID == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
