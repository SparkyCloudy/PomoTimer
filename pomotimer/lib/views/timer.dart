import 'package:flutter/material.dart';
import 'package:pomotimer/providers/history_provider.dart';
import 'package:pomotimer/providers/timer_provider.dart';
import 'package:provider/provider.dart';

class PomoTimer extends StatefulWidget {
  const PomoTimer({super.key});

  @override
  State<StatefulWidget> createState() => _PomoTimer();
}

class _PomoTimer extends State<PomoTimer> {
  late final TimerProvider timerProvider;

  @override
  void initState() {
    super.initState();
    context.read<TimerProvider>().fetchDurationFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    timerProvider.historyProvider = context.watch<HistoryProvider>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRoundsCounter(75, timerProvider),
              _buildCountdownTimer(150, timerProvider),
              _buildGoalsCounter(75, timerProvider),
            ],
          ),
          _buildBackgroundCircles(context),
        ]),
        _buildControlButtons(timerProvider),
      ],
    );
  }

  Widget _buildRoundsCounter(double size, TimerProvider timerProvider) {
    return Column(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            value: timerProvider.roundCounterAnimController.value,
            strokeWidth: size / 10,
            semanticsLabel: "Round",
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Round",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer(double size, TimerProvider timerProvider) {
    return Column(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: !timerProvider.isBreakTime
              ? CircularProgressIndicator(
                  value: timerProvider.timerAnimController.value,
                  strokeWidth: size / 10,
                  semanticsLabel: "Focus Countdown Timer",
                )
              : CircularProgressIndicator(
                  value: timerProvider.breakAnimController.value,
                  strokeWidth: size / 10,
                  color: Colors.red,
                  semanticsLabel: "Break Countdown Timer",
                ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Time",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsCounter(double size, TimerProvider timerProvider) {
    return Column(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            value: timerProvider.goalCounterAnimController.value,
            strokeWidth: size / 10,
            semanticsLabel: "Goal",
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Goal",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundCircles(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildCircleBackground(75, context),
        _buildCircleBackground(150, context),
        _buildCircleBackground(75, context),
      ],
    );
  }

  Widget _buildCircleBackground(double size, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor.withAlpha(15),
            value: 1.0,
            strokeWidth: size / 10,
            semanticsLabel: "Background",
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "",
            style: TextStyle(fontSize: 20, color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(TimerProvider timerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildIconButton(
          75,
          text: "Restart All",
          Icons.restart_alt,
          () => timerProvider.restartAll(),
          context,
        ),
        _buildIconButton(
          150,
          text: "Play/Pause",
          AnimatedIcons.play_pause as Object,
          timerProvider.isBreakTime ? null : () => timerProvider.buttonTimerAction(),
          context,
          isAnimated: true,
          animationController: timerProvider.startPauseAnimController,
        ),
        !timerProvider.isTimerCleared && !timerProvider.isBreakTime
            ? _buildIconButton(
                75,
                text: "Stop",
                Icons.stop,
                () => timerProvider.restartTimerCountdown(),
                context,
              )
            : const SizedBox(width: 91, height: 75),
      ],
    );
  }

  Widget _buildIconButton(
      double size, Object icon, VoidCallback? onPressed, BuildContext context,
      {bool isAnimated = false,
      AnimationController? animationController,
      required String text}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Ink(
            width: size,
            height: size,
            decoration: ShapeDecoration(
              color: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
            ),
            child: isAnimated
                ? IconButton(
                    onPressed: onPressed,
                    icon: AnimatedIcon(
                      icon: icon as AnimatedIconData,
                      size: size / 1.5,
                      progress: animationController!,
                    ),
                    color: Theme.of(context).canvasColor,
                  )
                : IconButton(
                    onPressed: onPressed,
                    icon: Icon(
                      icon as IconData,
                      size: size / 1.5,
                    ),
                    color: Theme.of(context).canvasColor,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
