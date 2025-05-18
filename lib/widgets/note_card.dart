import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notification_demo/services/firestore.dart';
import 'package:notification_demo/services/notification_service.dart';

class NoteTile extends StatelessWidget {
  final DocumentSnapshot document;
  final Function(String docID, String existingText) onEdit;

  const NoteTile({
    Key? key,
    required this.document,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final docID = document.id;
    final data = document.data() as Map<String, dynamic>;
    final noteText = data['note'];

    return ListTile(
      title: Text(noteText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => onEdit(docID, noteText),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await firestoreService.deleteNote(docID);
              await NotificationService.createNotification(
                id: 2,
                title: 'Note deleted',
                body: 'Your note "$noteText" was deleted.',
                summary: 'Deleted successfully <3',
              );
            },
          ),
        ],
      ),
    );
  }
}
