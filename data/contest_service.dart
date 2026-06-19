import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ContestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _imgBbApiKey = String.fromEnvironment('IMGBB_API_KEY', defaultValue: '786deb35e82ccb5461320d6cf3ac72c4'); 

  Stream<List<ExtendedMatchData>> getContests() {
    return _firestore
        .collection('contests')
        .orderBy('matchTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapDocToMatchData).toList());
  }

  Stream<ExtendedMatchData> getContestStream(String contestId) {
    return _firestore.collection('contests').doc(contestId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Contest not found');
      return _mapSingleDocToMatchData(doc);
    });
  }

  Future<void> joinContest({
    required String contestId,
    required String uid,
    required String username,
    required String gameIdUsed,
    File? paymentScreenshot,
    required bool isFree,
  }) async {
    try {
      String imageUrl = '';
      if (!isFree && paymentScreenshot != null) {
        if (_imgBbApiKey.isEmpty) {
          throw Exception("ImgBB API Key is missing. Please restart app with your Key.");
        }
        final List<int> imageBytes = await paymentScreenshot.readAsBytes();
        final String base64Image = base64Encode(imageBytes);
        final response = await http.post(
          Uri.parse('https://api.imgbb.com/1/upload'),
          body: {'key': _imgBbApiKey, 'image': base64Image},
        );
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          imageUrl = jsonResponse['data']['url'];
        } else {
          throw Exception('ImgBB Upload Failed code: ${response.statusCode}');
        }
      }

      final batch = _firestore.batch();
      final participantRef = _firestore.collection('contests').doc(contestId).collection('participants').doc(uid);
      final userJoinedRef = _firestore.collection('users').doc(uid).collection('joined_contests').doc(contestId);

      batch.set(participantRef, {
        'uid': uid,
        'username': username,
        'gameIdUsed': gameIdUsed,
        'paymentStatus': isFree ? 'Approved' : 'Pending',
        'paymentScreenshotUrl': imageUrl,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      batch.set(userJoinedRef, {
        'joinedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Registration Error: $e');
    }
  }

  ExtendedMatchData _mapSingleDocToMatchData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final gameName = data['gameName'] ?? data['game'] ?? 'Unknown';
    return ExtendedMatchData.fromFirestore(data, doc.id, _gameIconCodeFor(gameName), _gradientForGame(gameName));
  }

  ExtendedMatchData _mapDocToMatchData(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final gameName = data['gameName'] ?? data['game'] ?? 'Unknown';
    return ExtendedMatchData.fromFirestore(data, doc.id, _gameIconCodeFor(gameName), _gradientForGame(gameName));
  }

  int _gameIconCodeFor(String gameName) {
    switch (gameName.toLowerCase()) {
      case 'free fire': return 0xe518;
      case 'bgmi': return 0xe759;
      case 'valorant': return 0xe664;
      case 'ea fc': return 0xe51b;
      case 'clash royale': return 0xe69a;
      case 'apex legends':
      case 'apex': return 0xeb9b;
      case 'real cricket 26': return 0xe531;
      default: return 0xe318;
    }
  }

  List<int> _gradientForGame(String gameName) {
    switch (gameName.toLowerCase()) {
      case 'free fire': return const [0xFFFF6B00, 0xFFFF8F00];
      case 'bgmi': return const [0xFF4CAF50, 0xFF00E676];
      case 'valorant': return const [0xFFFF4081, 0xFFFF80AB];
      case 'ea fc': return const [0xFF2979FF, 0xFF448AFF];
      case 'clash royale': return const [0xFF7C4DFF, 0xFFB388FF];
      case 'apex legends':
      case 'apex': return const [0xFFFF3D00, 0xFFFF6E40];
      case 'real cricket 26': return const [0xFFFFAB00, 0xFFFFD740];
      default: return const [0xFF00B8D4, 0xFF00E5FF];
    }
  }
}