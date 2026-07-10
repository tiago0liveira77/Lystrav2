import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Personal data paths: users/{uid}/items, users/{uid}/lists, etc.
  CollectionReference<Map<String, dynamic>> userCollection(
    String uid,
    String sub,
  ) =>
      _db.collection('users').doc(uid).collection(sub);

  DocumentReference<Map<String, dynamic>> userDoc(
    String uid,
    String sub,
    String id,
  ) =>
      _db.collection('users').doc(uid).collection(sub).doc(id);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(String path) =>
      _db.doc(path).get();

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String path) =>
      _db.collection(path).get();

  Future<void> setDoc(String path, Map<String, dynamic> data) =>
      _db.doc(path).set(data);

  Future<DocumentReference<Map<String, dynamic>>> addDoc(
    String collectionPath,
    Map<String, dynamic> data,
  ) =>
      _db.collection(collectionPath).add(data);

  Future<void> updateDoc(String path, Map<String, dynamic> data) =>
      _db.doc(path).update(data);

  Future<void> deleteDoc(String path) => _db.doc(path).delete();

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(String path) =>
      _db.collection(path).snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDoc(String path) =>
      _db.doc(path).snapshots();
}
