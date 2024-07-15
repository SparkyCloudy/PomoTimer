class TimerData {
  String focusTime;
  String breakTime;
  int rounds;
  int goals;

  TimerData({
    this.focusTime = '00:25',
    this.breakTime = '00:05',
    this.rounds = 1,
    this.goals = 1
  });

  Map<String, dynamic> toMap() {
    return {
      'focus': focusTime,
      'break': breakTime,
      'rounds': rounds,
      'goals': goals
    };
  }

  factory TimerData.fromMap(Map<String, dynamic> map) {
    return TimerData(
      focusTime: map['focus'],
      breakTime: map['break'],
      rounds: map['rounds'],
      goals: map['goals']
    );
  }
}
