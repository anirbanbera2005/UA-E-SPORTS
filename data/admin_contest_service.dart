import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AdminContestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _imgBbApiKey = String.fromEnvironment('IMGBB_API_KEY', defaultValue: '786deb35e82ccb5461320d6cf3ac72c4'); 

  String generateContestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomSuffix = timestamp.substring(timestamp.length - 6);
    return 'UA-$randomSuffix';
  }

  Future<void> createContest({
    required String contestId,
    required Map<String, dynamic> contestData,
    Uint8List? qrImageBytes,
    String? qrImageExt,
  }) async {
    try {
      String qrImageUrl = '';
      if (qrImageBytes != null) {
        if (_imgBbApiKey.isEmpty) throw Exception("ImgBB API Key missing");

        final String base64Image = base64Encode(qrImageBytes);
        final response = await http.post(
          Uri.parse('https://api.imgbb.com/1/upload'),
          body: {'key': _imgBbApiKey, 'image': base64Image},
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          qrImageUrl = jsonResponse['data']['url'];
        } else {
          throw Exception('ImgBB Admin Upload Failure: ${response.statusCode}');
        }
      }

      if (qrImageUrl.isNotEmpty) {
        contestData['paymentConfig'] = contestData['paymentConfig'] ?? {};
        contestData['paymentConfig']['qrImageUrl'] = qrImageUrl;
      }
      await _firestore.collection('contests').doc(contestId).set(contestData);
    } catch (e) {
      throw Exception('Failed to create contest: $e');
    }
  }

  Stream<QuerySnapshot> getAllContests() {
    return _firestore.collection('contests').orderBy('matchTime', descending: true).snapshots();
  }

  Future<void> deleteContest(String contestId) async {
    await _firestore.collection('contests').doc(contestId).delete();
  }
}