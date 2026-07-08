import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  // Tukar dengan Cloud Name korang dari Cloudinary Dashboard
  final String cloudName = "profile_upload";

  // Tukar dengan nama upload preset yang korang buat tadi
  final String uploadPreset = "profile_images";

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<String> uploadProfileImage(File image) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    var request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] = "profile_$uid" // nama fail konsisten ikut UID
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);
      String imageUrl = data['secure_url'];
      return imageUrl;
    } else {
      final resBody = await response.stream.bytesToString();
      throw Exception("Failed upload: ${response.statusCode} - $resBody");
    }
  }
}