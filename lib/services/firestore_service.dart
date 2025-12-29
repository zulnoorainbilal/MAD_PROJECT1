import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user with UID as document ID (ROLE-BASED COLLECTION)
  Future<void> saveUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String userType,
  }) async {
    String collectionName;

    // 🔐 Role-based collections
    if (userType == "General staff") {
      collectionName = "general_staff";
    } else if (userType == "Food Donor") {
      collectionName = "food_donors";
    } else if (userType == "Resturant_Chef_Staff") {
      collectionName = "restaurant_staff";
    } else {
      throw Exception("Invalid user type");
    }

    await _db.collection(collectionName).doc(uid).set({
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userType': userType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Save waste log (UNCHANGED ✅)
  Future<void> saveWaste({
    required int grams,
    required String foodType,
    required String enteredBy, // usually UID or email
  }) async {
    await _db.collection('waste_logs').add({
      'grams': grams,
      'foodType': foodType,
      'enteredBy': enteredBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get waste logs (UNCHANGED ✅)
  Stream<QuerySnapshot> getWasteLogs() {
    return _db
        .collection('waste_logs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get user by UID & ROLE (UPDATED, backward-safe)
  Future<DocumentSnapshot?> getUserById(
    String uid,
    String userType,
  ) async {
    String collectionName;

    if (userType == "General staff") {
      collectionName = "general_staff";
    } else if (userType == "Food Donor") {
      collectionName = "food_donors";
    } else if (userType == "Resturant_Chef_Staff") {
      collectionName = "restaurant_staff";
    } else if (userType == "Admin") {
      collectionName = "admins";
    } else {
      return null;
    }

    return await _db.collection(collectionName).doc(uid).get();
  }
}
