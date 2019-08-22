import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:simple_news/models/news.dart';
import 'package:simple_news/models/tags.dart';
import 'package:simple_news/models/user.dart';
// import 'dart:convert';

class DatabaseService {
  final Firestore _db = Firestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get's user data passed in by uid of user logged in
  Stream<User> streamUser(String uid) {
    var ref = _db.collection('users').document(uid);
    return ref.snapshots().map((doc) => User.fromFirestore(doc));
  }

  // This gets the tasks created by user logged in and category they are in
  Stream<List<Tag>> streamTags(String uid) {
    var ref = _db
        .collection('users')
        .document(uid)
        .collection('tags')
        .orderBy('tag', descending: false);

    return ref.snapshots().map(
        (list) => list.documents.map((doc) => Tag.fromFirestore(doc)).toList());
  }

  Stream<List<News>> streamBookmarks(String uid) {
    var ref = _db
        .collection('users')
        .document(uid)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true);

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => News.fromFirestore(doc)).toList());
  }

  Future<void> addBookmark(String uid, News data) {
    Map<String, dynamic> newData = data.toJson();
    newData['uid'] = uid;
    newData['createdAt'] = DateTime.now();

    return _db
        .collection('users')
        .document(uid)
        .collection('bookmarks')
        .add(newData);
  }

  // this deletes the database document of user
  Future<void> deleteUser(String uid) {
    return _db.collection('users').document(uid).delete();
  }

  // this opens up image picker on device, and allows user to
  // upload to the firebase database.

  Future<void> uploadProfilePicture(FirebaseUser user) async {
    UserUpdateInfo userUpdateData = new UserUpdateInfo();

    File _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (_image != null) {
      var imagePath = _image.path;

      String fileName = imagePath.split('/').last;

      StorageReference reference =
          _storage.ref().child('users/${user.uid}/images/$fileName');

      StorageUploadTask uploadTask = reference.putFile(_image);

      String location =
          await (await uploadTask.onComplete).ref.getDownloadURL();
      userUpdateData.photoUrl = location;
      userUpdateData.displayName = user.displayName;
      user.updateProfile(userUpdateData);
      var now = DateTime.now();
      var data = {'imgUrl': location, 'uid': user.uid, 'createdAt': now};
      _db
          .collection('users')
          .document(user.uid)
          .updateData({'profile_pic': location});
      _db.collection('photo_content').add(data);
    }
  }
}
