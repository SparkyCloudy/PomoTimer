import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomotimer/providers/config_provider.dart';
import 'package:pomotimer/providers/timer_provider.dart';
import 'package:provider/provider.dart';

class PomoConfig extends StatefulWidget {
  const PomoConfig({super.key});

  @override
  State<StatefulWidget> createState() => _PomoConfigState();
}

class _PomoConfigState extends State<PomoConfig> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ConfigProvider>().getTimerData();
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigProvider>();
    final timerProvider = context.watch<TimerProvider>();

    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Timer Config',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: !timerProvider.isTimerCleared ? null : () {
                        _clearWidget(configProvider);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
                'If config Disabled, please press Restart All button on Timer Page'),
            const SizedBox(height: 12),
            _buildTimeInputField(
              controller: configProvider.focusTextController,
              enabled: !timerProvider.isRunning && timerProvider.isTimerCleared,
              label: 'Focus Time',
              icon: Icons.pending_actions,
              initialTime: configProvider.focusTime,
              onTimeSelected: (time) {
                configProvider.focusTime = time;
                configProvider.isSaved = false;
              },
            ),
            const SizedBox(height: 16),
            _buildTimeInputField(
              controller: configProvider.breakTextController,
              enabled: !timerProvider.isRunning && timerProvider.isTimerCleared,
              label: 'Break Time',
              icon: Icons.coffee,
              initialTime: configProvider.breakTime,
              onTimeSelected: (time) {
                configProvider.breakTime = time;
                configProvider.isSaved = false;
              },
            ),
            const SizedBox(height: 16),
            _buildNumericInputField(
              controller: configProvider.roundTextController,
              label: 'Rounds',
              enabled: !timerProvider.isRunning && timerProvider.isTimerCleared,
            ),
            const SizedBox(height: 16),
            _buildNumericInputField(
              controller: configProvider.goalTextController,
              label: 'Goals',
              enabled: !timerProvider.isRunning && timerProvider.isTimerCleared,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: configProvider.isSaveButtonEnabled
                  ? () => configProvider.handleSaveOperation(_formKey, context)
                  : null,
              child: const Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericInputField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      validator: context.read<ConfigProvider>().validateNumberInput,
      onChanged: (value) {
        setState(() {
          context.read<ConfigProvider>().isSaved = false;
        });
      },
    );
  }

  Widget _buildTimeInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TimeOfDay initialTime,
    required Function(TimeOfDay) onTimeSelected,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: true,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        labelText: label,
        hintText: 'HH:mm',
      ),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          helpText: "Enter $label",
          context: context,
          initialTime: initialTime,
          initialEntryMode: TimePickerEntryMode.inputOnly,
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (mounted) {
          context
              .read<ConfigProvider>()
              .handleTimeSelection(picked, label, controller, onTimeSelected);
        }
      },
    );
  }

  void _clearWidget(ConfigProvider configProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear Form"),
          content: const Text(
            "Are you sure you want to change to the default value?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                configProvider.clearForm(context);
              },
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );
  }
}
