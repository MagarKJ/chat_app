import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/user_profile.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _usersCollection;

  DatabaseService() {
    _setupCollectionReferences();
  }

  void _setupCollectionReferences() async {
    try {
      // Reference to the Firestore "users" collection
      _usersCollection =
          _firestore.collection('users').withConverter<UserProfile>(
                fromFirestore: (snapshot, _) =>
                    UserProfile.fromJson(snapshot.data()!),
                toFirestore: (userProfile, _) => userProfile.toJson(),
              );
    } catch (e) {
      print("❌ Error saving to Firestore: $e");
    }
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection?.doc(userProfile.uid).set(userProfile);
    } catch (e) {
      print("❌ Error saving to Firestore: $e");
    }
  }
}
