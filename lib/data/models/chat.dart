import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String productId;
  final String? productName;
  final List<String> participants;
  final String? lastMessage;
  final DateTime lastUpdated;

  Chat({
    required this.id,
    required this.productId,
    this.productName,
    required this.participants,
    this.lastMessage,
    required this.lastUpdated,
  });

  factory Chat.fromMap(Map<String, dynamic> map, String id) {
    return Chat(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'],
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  Chat copyWith({
    String? lastMessage,
    DateTime? lastUpdated,
  }) {
    return Chat(
      id: id,
      productId: productId,
      productName: productName,
      participants: participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}
