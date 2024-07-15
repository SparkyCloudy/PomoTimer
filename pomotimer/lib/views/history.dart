import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomotimer/providers/history_provider.dart';
import 'package:provider/provider.dart';

class PomoHistory extends StatefulWidget {
  const PomoHistory({super.key});

  @override
  State<StatefulWidget> createState() => _PomoHistory();
}

class _PomoHistory extends State<PomoHistory> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryProvider>().fetchHistoryEvents();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer History'),
        actions: <Widget>[
          TextButton(
            onPressed: historyProvider.history.isEmpty
                ? null
                : () {
                    historyProvider.clearHistory();
                  },
            child: const Text('Clear History'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: historyProvider.history.length,
        itemBuilder: (context, index) {
          index++;
          final event = historyProvider
              .history[historyProvider.history.length - index];
          return ListTile(
            title: Text(event.event),
            subtitle:
                Text(DateFormat('dd/MM/yyyy hh:mm:ss').format(event.timestamp)),
          );
        },
      ),
    );
  }
}
