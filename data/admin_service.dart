import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updatePaymentStatus(String contestId, String uid, String status) async {
    await _firestore
        .collection('contests')
        .doc(contestId)
        .collection('participants')
        .doc(uid)
        .update({'paymentStatus': status});
  }

  Future<void> updateRoomDetails(String contestId, String roomId, String password) async {
    await _firestore.collection('contests').doc(contestId).update({
      'roomId': roomId,
      'roomPassword': password,
    });
  }

  Future<void> publishLeaderboard(String contestId, List<Map<String, dynamic>> winners) async {
    final batch = _firestore.batch();
    
    for (var winner in winners) {
      final uid = winner['uid'];
      final prize = (winner['prize'] as num).toDouble();
      
      if (prize <= 0) continue;
      
      final userRef = _firestore.collection('users').doc(uid);
      final transactionRef = userRef.collection('transactions').doc(); 
      
      batch.set(transactionRef, {
        'type': 'credit',
        'description': 'Prize won in Contest $contestId',
        'amount': prize,
        'time': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      batch.set(userRef, {
        'wallet': {
          'balance': FieldValue.increment(prize),
          'withdrawable': FieldValue.increment(prize),
        },
        'stats': {
          'totalEarnings': FieldValue.increment(prize),
          'top3Wins': FieldValue.increment(1), 
          'totalCompletedMatches': FieldValue.increment(1),
        }
      }, SetOptions(merge: true));
    }
    
    final contestRef = _firestore.collection('contests').doc(contestId);
    batch.update(contestRef, {'status': 'Results Declared'});
    await batch.commit();
  }

  Stream<QuerySnapshot> getPendingPayments(String contestId) {
    return _firestore
        .collection('contests')
        .doc(contestId)
        .collection('participants')
        .where('paymentStatus', isEqualTo: 'Pending')
        .snapshots();
  }
}