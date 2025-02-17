import 'dart:developer';

import 'package:chat_app/model/chat.dart';
import 'package:chat_app/model/message.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../model/user_profile.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AuthServices _authServices;
  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;

  DatabaseService() {
    _authServices = _getIt.get<AuthServices>();
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
      _chatsCollection = _firestore.collection('chats').withConverter<Chat>(
            fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
            toFirestore: (chat, _) => chat.toJson(),
          );
    } catch (e) {
      log("❌ Error saving to Firestore: $e");
    }
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection?.doc(userProfile.uid).set(userProfile);
    } catch (e) {
      log("❌ Error saving to Firestore: $e");
    }
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfile() {
    return _usersCollection
        ?.where('uid', isNotEqualTo: _authServices.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists({required String uid1, uid2}) async {
    try {
      String chatID = generateChatID(uid1: uid1, uid2: uid2);
      final result = await _chatsCollection?.doc(chatID).get();
      if (result != null) {
        return result.exists;
      }
      return false;
    } catch (e) {
      log("❌ Error fetching chat: $e");
      return false;
    }
  }

  Future<void> createNewChat({required String uid1, uid2}) async {
    try {
      String chatID = generateChatID(uid1: uid1, uid2: uid2);
      final docRef = _chatsCollection!.doc(chatID);
      final chat = Chat(
        id: chatID,
        participants: [uid1, uid2],
        messages: [],
      );
      await docRef.set(chat);
    } catch (e) {
      log("❌ Error creating chat: $e");
    }
  }

  Future<void> sendChatMessage(
      {required String uid1, uid2, required Message message}) async {
    try {
      String chatID = generateChatID(uid1: uid1, uid2: uid2);
      final docRef = _chatsCollection!.doc(chatID);

      await docRef.update(
        {
          'messages': FieldValue.arrayUnion(
            [
              message.toJson(),
            ],
          ),
        },
      );
    } catch (e) {
      log("❌ Error sending message: $e");
    }
  }

  Stream<DocumentSnapshot<Chat>> getChatData({required String uid1, uid2}) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
