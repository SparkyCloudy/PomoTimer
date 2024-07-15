import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomotimer/providers/config_provider.dart';
import 'package:pomotimer/providers/history_provider.dart';
import 'package:pomotimer/providers/timer_provider.dart';
import 'package:pomotimer/views/home.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerProvider(this)),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
        ChangeNotifierProvider(create: (context) => ConfigProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PomoTimer',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const FixedUi(title: 'PomoTimer Home Page'),
      ),
    );
  }
}