import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Central access point for the app's Firestore data.
///
/// Collections used by DapurKasih:
///   users/{uid}            - user profile (name, memberId, email, phone, role...)
///   bookings/{autoId}      - kitchen slot bookings
///   damage_reports/{autoId} - kitchen damage reports
class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Read the uid lazily so the service can be constructed before login.
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // ---------------------------------------------------------
  // USER PROFILE
  // ---------------------------------------------------------

  /// Stores the profile photo as base64 inside the user document.
  /// (Firebase Storage is not enabled on the `dapurkasih` project, so the
  /// photo lives in Firestore instead — images are resized before saving
  /// to stay well under the 1 MB document limit.)
  Future<void> updateImageBase64(String imageBase64) async {
    await firestore.collection("users").doc(uid).set({
      "imageBase64": imageBase64,
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

  /// Creates the profile document right after signup.
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String memberId,
    required String email,
    required String phone,
    required String dob,
    String role = "student",
  }) async {
    await firestore.collection("users").doc(userId).set({
      "name": name,
      "memberId": memberId,
      "email": email,
      "phone": phone,
      "address": "",
      "dob": dob,
      "imageUrl": "",
      "role": role,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Returns the role stored for [userId] ("student" when missing).
  Future<String> getUserRole(String userId) async {
    final doc = await firestore.collection("users").doc(userId).get();
    final data = doc.data();
    return (data?["role"] as String?) ?? "student";
  }

  // ---------------------------------------------------------
  // BOOKINGS
  // ---------------------------------------------------------

  /// All bookings made by the current user (sorted client-side to
  /// avoid needing a composite Firestore index).
  Stream<QuerySnapshot> getMyBookings() {
    return firestore
        .collection("bookings")
        .where("userId", isEqualTo: uid)
        .snapshots();
  }

  Future<void> updateBooking(
    String bookingId, {
    required String purpose,
    required String members,
    required int totalUsers,
  }) async {
    await firestore.collection("bookings").doc(bookingId).update({
      "purpose": purpose,
      "members": members,
      "totalUsers": totalUsers,
    });
  }

  /// Cancelling a booking removes the record so the slot becomes
  /// available again (report §3.5 DELETE).
  Future<void> cancelBooking(String bookingId) async {
    await firestore.collection("bookings").doc(bookingId).delete();
  }

  // ---------------------------------------------------------
  // DAMAGE REPORTS
  // ---------------------------------------------------------

  /// All damage reports submitted by the current user.
  Stream<QuerySnapshot> getMyDamageReports() {
    return firestore
        .collection("damage_reports")
        .where("userId", isEqualTo: uid)
        .snapshots();
  }
}
