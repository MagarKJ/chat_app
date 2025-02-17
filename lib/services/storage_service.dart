import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String clientId =
      "9142a9da32949ae"; // imagur ko client id kina ki firebase storage lai paisa lagyo

  Future<String?> uploadUserPfp({
    required File file,
    required String uid,
  }) async {
    try {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path),
      });
      Response response = await dio.post(
        'https://api.imgur.com/3/image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Client-ID $clientId',
          },
        ),
      );
      if (response.statusCode == 200) {
        log(response.data.toString());
        // saveImageUrlToFirestore(uid, response.data['data']['link']);
        return response.data['data']['link']; // image url
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // Future<String?> uploadImageToChat({ required File file }) async {
  //   try {
  //     Dio dio = Dio();
  //     FormData formData = FormData.fromMap({
  //       'image': await MultipartFile.fromFile(file.path),
  //     });
  //     Response response = await dio.post(
  //       'https://api.imgur.com/3/image',
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Client-ID $clientId',
  //         },
  //       ),
  //     );
  //     if (response.statusCode == 200) {
  //       log(response.data.toString());
  //       return response.data['data']['link']; // image url
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //   }
  //   return null;
  // }

  Future<void> saveImageUrlToFirestore(String uid, String imageUrl) async {
    // save image url to firestore
    try {
      // Reference to the Firestore "users" collection
      CollectionReference users = _firestore.collection('users');

      // Save the URL to the user's document, path: 'users/pfps/$uid'
      await users.doc(uid).set(
          {
            'profilePic':
                imageUrl, // Store the image URL under 'profilePic' field
          },
          SetOptions(
              merge: true)); // Use merge to prevent overwriting other data

      log("✅ Image URL saved to Firestore!");
    } catch (e) {
      log("❌ Error saving to Firestore: $e");
    }
  }
}
