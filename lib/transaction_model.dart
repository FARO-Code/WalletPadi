class WalletTransaction {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId; // Make sure this field exists
  final String toUserName;
  final double amount;
  final String note;
  final DateTime timestamp;

  WalletTransaction({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId, // This is crucial for received transactions
    required this.toUserName,
    required this.amount,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId, // Make sure this is included
      'toUserName': toUserName,
      'amount': amount,
      'note': note,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static WalletTransaction fromMap(Map<String, dynamic> map, String id) {
    return WalletTransaction(
      id: id,
      fromUserId: map['fromUserId'],
      fromUserName: map['fromUserName'],
      toUserId: map['toUserId'], // Make sure this is included
      toUserName: map['toUserName'],
      amount: map['amount'].toDouble(),
      note: map['note'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}