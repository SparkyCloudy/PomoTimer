class HistoryEvent {
  int? id;
  String event;
  DateTime timestamp;

  HistoryEvent({this.id, required this.event, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event': event,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryEvent.fromMap(Map<String, dynamic> map) {
    return HistoryEvent(
      id: map['id'],
      event: map['event'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}