import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Reference to the "notes" collection in Firestore
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  /// Add a new note
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  /// Get notes as a real-time stream
  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  /// Update an existing note by document ID
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  /// Delete a note by document ID
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
