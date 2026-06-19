import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserProfile> getUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return UserProfile(uid: uid, name: 'Player', email: '', avatarLetter: 'P');
      }
      return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<WalletData> getUserWallet(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncMap((doc) async {
      
      if (!doc.exists) return WalletData();
      
      final data = doc.data() as Map<String, dynamic>;
      final wallet = data['wallet'] as Map<String, dynamic>? ?? {};
      
      final txSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('time', descending: true)
          .limit(20)
          .get();

      List<TransactionData> transactions = txSnapshot.docs.map((tDoc) {
        final tData = tDoc.data();
        return TransactionData(
          id: tDoc.id,
          type: tData['type'] ?? '',
          description: tData['description'] ?? '',
          amount: (tData['amount'] ?? 0).toDouble(),
          time: (tData['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: tData['status'] ?? 'completed',
        );
      }).toList();

      return WalletData(
        balance: (wallet['balance'] ?? 0).toDouble(),
        bonus: (wallet['bonus'] ?? 0).toDouble(),
        withdrawable: (wallet['withdrawable'] ?? 0).toDouble(),
        transactions: transactions,
      );
    });
  }

  Future<void> updateGameId(String uid, String gameName, String gameId) async {
    await _firestore.collection('users').doc(uid).set({
      'gameIds': {gameName: gameId}
    }, SetOptions(merge: true));
  }
}