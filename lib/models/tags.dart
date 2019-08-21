import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String tag;
  final String title;
  final String uid;
  final String id;

  Tag({
    this.tag,
    this.title,
    this.uid,
    this.id,
  });

  factory Tag.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    if (data == null) {
      return Tag.initialData();
    } else {
      return Tag(
          uid: doc.documentID,
          title: data['title'] ?? 'loading',
          tag: data['tag'] ?? 'loading',
          id: doc.documentID ?? null);
    }
  }

  factory Tag.initialData() {
    return Tag(uid: null, title: 'loading', tag: 'loading', id: null);
  }
}
