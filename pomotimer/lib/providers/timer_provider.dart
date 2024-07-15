import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pomotimer/helpers/database.dart';
import 'package:pomotimer/models/history_model.dart';
import 'package:pomotimer/models/timer_model.dart';
import 'package:pomotimer/providers/history_provider.dart';

class TimerProvider extends ChangeNotifier {
  late AnimationController timerAnimController,
      breakAnimController,
      roundCounterAnimController,
      goalCounterAnimController,
      startPauseAnimController;

  int _timerDuration = 1500; // seconds
  int _breakDuration = 300;
  int _roundDuration = 4;
  int _goalDuration = 2;

  int timerElapsed = 0;
  int breakElapsed = 0;
  int goalElapsed = 0;
  int roundElapsed = 0;

  bool isRunning = false;
  bool isTimerCleared = true;
  bool isBreakTime = false;

  Timer? _timer;
  final DbHelper _dbHelper = DbHelper();
  late HistoryProvider historyProvider;

  TimerProvider(TickerProvider vsync) {
    timerAnimController = AnimationController(
        vsync: vsync, duration: Duration(seconds: _timerDuration));
    breakAnimController = AnimationController(
        vsync: vsync, duration: Duration(seconds: _breakDuration));
    roundCounterAnimController = AnimationController(vsync: vsync);
    goalCounterAnimController = AnimationController(vsync: vsync);
    startPauseAnimController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 250));
    notifyListeners();
  }

  Future<void> fetchDurationFromDatabase() async {
    TimerData? timerData = await _dbHelper.getTimer();
    if (timerData != null) {
      List<String> focusTimeParts = timerData.focusTime.split(':');
      List<String> breakTimerParts = timerData.breakTime.split(':');

      int focusHours = int.parse(focusTimeParts[0]);
      int focusMinutes = int.parse(focusTimeParts[1]);
      int breakHours = int.parse(breakTimerParts[0]);
      int breakMinutes = int.parse(breakTimerParts[1]);

      _roundDuration = timerData.rounds;
      _goalDuration = timerData.goals;

      _timerDuration = (focusHours * 60 + focusMinutes) * 60;
      _breakDuration = (breakHours * 60 + breakMinutes) * 60;

      timerAnimController.duration = Duration(seconds: _timerDuration);
      breakAnimController.duration = Duration(seconds: _breakDuration);
    }
  }

  void startTimer({required String text}) {
    if (!isRunning) {
      isRunning = true;
      isTimerCleared = false;

      logEvent("$text Timer Started");

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        timerElapsed++;
        timerAnimController.value = timerElapsed / _timerDuration;

        if (timerElapsed >= _timerDuration) {
          stopTimer(text: "Focus");
          _handleTimerEnd();
        }
        notifyListeners();
      });
    }
  }

  void startBreakTimer() {
    if (!isRunning) {
      timerElapsed = 0;
      breakElapsed = 0;

      isRunning = true;
      isBreakTime = true;

      timerAnimController.value = 0;

      logEvent("Break Timer Started");

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        breakElapsed++;
        breakAnimController.value = breakElapsed / _breakDuration;

        if (breakElapsed >= _breakDuration) {
          stopTimer(switchToBreak: false, text: "Break");
          isBreakTime = false;
        }
        notifyListeners();
      });
    }
  }

  void restartTimerCountdown() {
    timerElapsed = 0;
    breakElapsed = 0;
    timerAnimController.value = 0;
    breakAnimController.value = 0;
    startPauseAnimController.reverse();

    if (isRunning) {
      _timer?.cancel();
      isRunning = false;
      logEvent("Timer Countdown Restarted");
    }

    notifyListeners();
  }

  void stopTimer({required String text, bool switchToBreak = false}) {
    if (isRunning) {
      _timer?.cancel();
      isRunning = false;

      logEvent("$text Timer Stopped");

      if (switchToBreak && timerElapsed >= _timerDuration && isBreakTime) {
        startBreakTimer();
      } else if (!switchToBreak && breakElapsed >= _breakDuration) {
        breakElapsed = 0;
        breakAnimController.value = 0;
        if (roundElapsed < _roundDuration || goalElapsed < _goalDuration) {
          startTimer(text: "Focus");
        } else {
          _handleSessionEnd();
        }
      }

      notifyListeners();
    }
  }

  void restartAll() {
    if (!isTimerCleared) {
      _timer?.cancel();
      isRunning = false;
      isTimerCleared = true;

      timerElapsed = 0;
      roundElapsed = 0;
      goalElapsed = 0;

      timerAnimController.value = 0;
      roundCounterAnimController.value = 0;
      goalCounterAnimController.value = 0;

      startPauseAnimController.reverse();

      logEvent("Timer Restarted All");

      notifyListeners();
    }
  }

  void buttonTimerAction() {
    if (!isRunning) {
      startPauseAnimController.forward();
      startTimer(text: "Focus");
    } else {
      startPauseAnimController.reverse();
      stopTimer(text: "Focus");
    }
  }

  void logEvent(String event) async {
    HistoryEvent historyEvent =
        HistoryEvent(event: event, timestamp: DateTime.now());
    historyProvider.addHistoryEvent(historyEvent);
  }

  void _handleTimerEnd() {
    roundElapsed++;
    logEvent("Round(s) $roundElapsed/$_roundDuration");
    roundCounterAnimController.value = roundElapsed / _roundDuration;

    if (roundElapsed >= _roundDuration) {
      logEvent("Reset Round(s)");
      roundElapsed = 0;
      goalElapsed++;
      logEvent("Goal(s) $goalElapsed/$_goalDuration");

      goalCounterAnimController.value = goalElapsed / _goalDuration;
      roundCounterAnimController.value = roundElapsed / _roundDuration;

      if (goalElapsed >= _goalDuration) {
        _handleSessionEnd();
        return;
      }

      startBreakTimer();
      return;
    }

    startBreakTimer();
    notifyListeners();
  }

  void _handleSessionEnd() {
    isRunning = false;
    isTimerCleared = true;

    timerElapsed = 0;
    roundElapsed = 0;
    goalElapsed = 0;

    timerAnimController.value = 0;
    roundCounterAnimController.value = 0;
    goalCounterAnimController.value = 0;

    startPauseAnimController.reverse();

    logEvent("Session Completed");

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
