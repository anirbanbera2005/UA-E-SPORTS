import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameData {
  final String name, shortCode;
  final int iconCodePoint;
  final List<int> gradientColors;
  final Map<String, String> specificFields;

  const GameData({
    required this.name,
    required this.shortCode,
    required this.iconCodePoint,
    required this.gradientColors,
    this.specificFields = const {},
  });
}

const Map<String, String> kGameLogoAsset = {
  'Free Fire': 'assets/logos/freefire.png',
  'BGMI': 'assets/logos/bgmi.png',
  'EA FC': 'assets/logos/eafc.png',
  'Cricket 26': 'assets/logos/cricket26.png',
  'Clash Royale': 'assets/logos/clash.png',
  'Valorant': 'assets/logos/valorant.png',
  'Apex': 'assets/logos/apex.png',
};

String gameLogoAssetFor(String gameName) => kGameLogoAsset[gameName] ?? 'assets/logos/freefire.png';

class MatchData {
  final String id, gameName, mapName, matchType, matchTag;
  final int gameIconCode;
  final List<int> gradientColors;
  final DateTime matchTime;
  final int prizePool, totalSlots, filledSlots, entryFee;
  final String difficulty;
  final double winProbability;
  final String status;

  const MatchData({
    required this.id,
    required this.gameName,
    required this.gameIconCode,
    required this.gradientColors,
    required this.matchTime,
    required this.prizePool,
    required this.totalSlots,
    required this.filledSlots,
    required this.entryFee,
    required this.mapName,
    required this.matchType,
    required this.matchTag,
    this.status = 'Upcoming',
    this.difficulty = 'Medium',
    this.winProbability = 0.3,
  });

  int get slotsLeft => max(0, totalSlots - filledSlots);
  bool get isFree => entryFee <= 0;
  double get fillRate => totalSlots == 0 ? 0 : (filledSlots / totalSlots).clamp(0.0, 1.0);
}

class ExtendedMatchData extends MatchData {
  final DateTime roomRevealTime;
  final String roomId;
  final String roomPassword;
  final String upiId;
  final String qrImageUrl;
  final List<String> rules;
  final Map<String, int> prizeDistribution;

  ExtendedMatchData({
    required super.id,
    required super.gameName,
    required super.gameIconCode,
    required super.gradientColors,
    required super.matchTime,
    required super.prizePool,
    required super.totalSlots,
    required super.filledSlots,
    required super.entryFee,
    required super.mapName,
    required super.matchType,
    required super.matchTag,
    super.status,
    required this.roomRevealTime,
    this.roomId = '',
    this.roomPassword = '',
    this.upiId = '',
    this.qrImageUrl = '',
    this.rules = const [],
    this.prizeDistribution = const {},
  });

  bool get isRoomRevealed => DateTime.now().toUtc().isAfter(roomRevealTime.toUtc());

  String get dynamicStatus {
    final now = DateTime.now().toUtc();
    final startTime = matchTime.toUtc();
    final endTime = startTime.add(const Duration(minutes: 40)); 
    if (now.isBefore(startTime)) return 'Upcoming';
    if (now.isAfter(endTime)) return 'Completed';
    return 'Live';
  }

  factory ExtendedMatchData.fromFirestore(Map<String, dynamic> data, String id, int iconCode, List<int> colors) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      return DateTime.now();
    }
    final paymentMap = data['paymentConfig'] as Map<String, dynamic>? ?? {};
    return ExtendedMatchData(
      id: id,
      gameName: data['gameName'] ?? data['game'] ?? 'Unknown',
      gameIconCode: iconCode,
      gradientColors: colors,
      matchTime: parseDate(data['matchTime']),
      roomRevealTime: parseDate(data['roomRevealTime'] ?? data['matchTime']),
      prizePool: (data['prizePool'] ?? 0).toInt(),
      totalSlots: (data['totalSlots'] ?? data['slots'] ?? 0).toInt(),
      filledSlots: (data['filledSlots'] ?? data['joinedPlayers'] ?? 0).toInt(),
      entryFee: (data['entryFee'] ?? 0).toInt(),
      mapName: data['mapName'] ?? '',
      matchType: data['mode'] ?? '',
      matchTag: data['playerSize'] ?? '',
      status: data['status'] ?? 'Upcoming',
      roomId: data['roomId'] ?? '',
      roomPassword: data['roomPassword'] ?? '',
      upiId: paymentMap['upiId'] ?? paymentMap['phonePeId'] ?? data['upiId'] ?? data['phonePeId'] ?? '',
      qrImageUrl: paymentMap['qrImageUrl'] ?? data['qrImageUrl'] ?? '',
      rules: List<String>.from(data['rules'] ?? []),
      prizeDistribution: Map<String, int>.from(data['prizeDistribution'] ?? {}),
    );
  }
}

class LeaderEntry {
  final int rank, kills, points, prize;
  final String username, uid;
  const LeaderEntry({
    required this.rank,
    required this.username,
    required this.uid,
    required this.kills,
    required this.points,
    required this.prize,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  const ChatMessage({required this.text, required this.isUser, required this.time});
}

class WalletData {
  double balance;
  double bonus;
  double withdrawable;
  List<TransactionData> transactions;
  WalletData({
    this.balance = 0,
    this.bonus = 0,
    this.withdrawable = 0,
    List<TransactionData>? transactions,
  }) : transactions = transactions ?? [];
}

class TransactionData {
  final String id, type, description;
  final double amount;
  final DateTime time;
  final String status;
  const TransactionData({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.time,
    required this.status,
  });
}

class UserProfile {
  final String name, uid, avatarLetter, email;
  final int totalMatches, wins, losses;
  final double totalEarnings, totalEntryFeesPaid;
  final Map<String, String> gameIds;
  final double balance;
  final double bonus;
  final double withdrawable;
  final int level, xp, maxXp;
  final double roi;
  final String rank, favoriteGame;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarLetter,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.totalEarnings = 0.0,
    this.totalEntryFeesPaid = 0.0,
    this.gameIds = const {},
    this.balance = 0.0,
    this.bonus = 0.0,
    this.withdrawable = 0.0,
    this.level = 1,
    this.xp = 0,
    this.maxXp = 1000,
    this.roi = 0.0,
    this.rank = 'Bronze',
    this.favoriteGame = 'Unknown',
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final wallet = data['wallet'] as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: id,
      name: data['name'] ?? 'Player',
      email: data['email'] ?? '',
      avatarLetter: (data['name'] != null && data['name'].toString().isNotEmpty) 
          ? data['name'][0].toUpperCase() 
          : 'P',
      totalMatches: (stats['totalCompletedMatches'] ?? 0).toInt(),
      wins: (stats['top3Wins'] ?? 0).toInt(),
      losses: (stats['losses'] ?? 0).toInt(),
      totalEarnings: (stats['totalEarnings'] ?? 0).toDouble(),
      totalEntryFeesPaid: (stats['totalEntryFees'] ?? 0).toDouble(),
      gameIds: Map<String, String>.from(data['gameIds'] ?? {}),
      balance: (wallet['balance'] ?? 0).toDouble(),
      bonus: (wallet['bonus'] ?? 0).toDouble(),
      withdrawable: (wallet['withdrawable'] ?? 0).toDouble(),
    );
  }
}

class ParticipantData {
  final String uid;
  final String username;
  final String gameIdUsed;
  final String paymentStatus;
  final String paymentScreenshotUrl;
  final DateTime joinedAt;

  ParticipantData({
    required this.uid,
    required this.username,
    required this.gameIdUsed,
    required this.paymentStatus,
    required this.paymentScreenshotUrl,
    required this.joinedAt,
  });

  factory ParticipantData.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ParticipantData(
      uid: documentId,
      username: data['username'] ?? 'Unknown',
      gameIdUsed: data['gameIdUsed'] ?? '',
      paymentStatus: data['paymentStatus'] ?? 'Pending',
      paymentScreenshotUrl: data['paymentScreenshotUrl'] ?? '',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

const kPlayerNames = ['ShadowKing','PhoenixOP','BlazeYT','StormGG','ViperX','GhostPro','SniperAce','FuryBoss','TitanFF','OmegaZ'];
const kSuffixes = ['_YT','xOP','007','_FF','Pro','GG','_X','99','King','Boss'];
String randomName(int seed) {
  final r = Random(seed);
  return '${kPlayerNames[r.nextInt(kPlayerNames.length)]}${kSuffixes[r.nextInt(kSuffixes.length)]}';
}
String randomUid(int seed) => '${1000000000 + Random(seed).nextInt(899999999)}';