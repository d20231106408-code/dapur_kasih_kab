import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> updateImage(String imageUrl) async {
    await firestore.collection("users").doc(uid).set({
      "imageUrl": imageUrl,
    }, SetOptions(merge: true));
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    await firestore.collection("users").doc(uid).set({
      "name": name,
      "phone": phone,
      "address": address,
      "email": FirebaseAuth.instance.currentUser!.email,
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getProfile() {
    return firestore.collection("users").doc(uid).snapshots();
  }
}