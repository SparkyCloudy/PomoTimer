import 'package:flutter/material.dart';
import 'package:pomotimer/helpers/database.dart';
import 'package:pomotimer/models/timer_model.dart';

class ConfigProvider extends ChangeNotifier {
  final DbHelper _db = DbHelper();

  TimeOfDay focusTime = const TimeOfDay(hour: 0, minute: 25);
  TimeOfDay breakTime = const TimeOfDay(hour: 0, minute: 5);

  late TextEditingController focusTextController;
  late TextEditingController breakTextController;
  late TextEditingController roundTextController;
  late TextEditingController goalTextController;

  bool isSaved = true;
  bool isTimeInputValid = true;

  bool get isSaveButtonEnabled => !isSaved && isTimeInputValid;

  ConfigProvider() {
    focusTextController = TextEditingController();
    breakTextController = TextEditingController();
    roundTextController = TextEditingController();
    goalTextController = TextEditingController();
    getTimerData();
  }

  Future<void> getTimerData() async {
    TimerData? timerData = await _db.getTimer();
    if (timerData != null) {
      focusTextController.text = timerData.focusTime;
      breakTextController.text = timerData.breakTime;
      roundTextController.text = timerData.rounds.toString();
      goalTextController.text = timerData.goals.toString();

      List<String> focusParts = timerData.focusTime.split(':');
      int focusHour = int.parse(focusParts[0]);
      int focusMinute = int.parse(focusParts[1]);
      focusTime = TimeOfDay(hour: focusHour, minute: focusMinute);

      List<String> breakParts = timerData.breakTime.split(':');
      int breakHour = int.parse(breakParts[0]);
      int breakMinute = int.parse(breakParts[1]);
      breakTime = TimeOfDay(hour: breakHour, minute: breakMinute);

      notifyListeners();
    }
  }

  void saveForm(BuildContext context) async {
    TimerData timerData = TimerData(
      focusTime: focusTextController.text,
      breakTime: breakTextController.text,
      rounds: int.tryParse(roundTextController.text) ?? 1,
      goals: int.tryParse(goalTextController.text) ?? 1,
    );

    await _db.updateTimer(timerData);

    if (context.mounted) {
      isSaved = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timer configuration saved!')),
      );
    }

    notifyListeners();
  }

  void clearForm(BuildContext context) async {
    focusTime = const TimeOfDay(hour: 0, minute: 25);
    breakTime = const TimeOfDay(hour: 0, minute: 5);

    focusTextController.text = const DefaultMaterialLocalizations()
        .formatTimeOfDay(focusTime, alwaysUse24HourFormat: true);
    breakTextController.text = const DefaultMaterialLocalizations()
        .formatTimeOfDay(breakTime, alwaysUse24HourFormat: true);
    roundTextController.text = '1';
    goalTextController.text = '1';

    saveForm(context);
    notifyListeners();

    Navigator.of(context).pop();
  }

  void handleSaveOperation(GlobalKey<FormState> formKey, BuildContext context) {
    if (formKey.currentState!.validate()) {
      saveForm(context);
    }
  }

  void handleTimeSelection(TimeOfDay? picked, String label,
      TextEditingController controller, Function(TimeOfDay) onTimeSelected) {
    if (picked != null) {
      if (picked.minute < 1) {
        isTimeInputValid = false;
      } else {
        isTimeInputValid = true;
        controller.text = const DefaultMaterialLocalizations()
            .formatTimeOfDay(picked, alwaysUse24HourFormat: true);
        onTimeSelected(picked);
      }
      notifyListeners();
    }
  }

  String? validateNumberInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field cannot be empty';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 1) {
      return 'Value must be at least 1';
    }
    return null;
  }

  @override
  void dispose() {
    focusTextController.dispose();
    breakTextController.dispose();
    roundTextController.dispose();
    goalTextController.dispose();
    super.dispose();
  }
}
