import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/timer_provider.dart';
import '../../services/timer_service.dart';
import '../painters/ring_painter.dart';
import '../widgets/description_sheet.dart';
import '../widgets/duration_adjuster.dart';
import '../widgets/ringing_overlay.dart';
import '../widgets/timer_controls.dart';

const _minDurationMinutes = 5;
const _maxDurationMinutes = 60;
const _durationStep = 5;

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  DateTime? _ringStartedAt;
  int _adjustedMinutes = 20;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _loadAdjustedMinutes();
  }

  Future<void> _loadAdjustedMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('timer_adjustedMinutes');
    if (!mounted) return;
    if (saved != null) {
      setState(() {
        _adjustedMinutes = saved;
      });
    } else {
      final timerState = ref.read(timerProvider);
      final fromState = (timerState.totalSeconds / 60).round();
      if (fromState >= _minDurationMinutes && fromState <= _maxDurationMinutes) {
        setState(() {
          _adjustedMinutes = fromState;
        });
      }
    }
  }

  Future<void> _saveAdjustedMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_adjustedMinutes', minutes);
  }

  void _incrementDuration() {
    final newMinutes = (_adjustedMinutes + _durationStep).clamp(
      _minDurationMinutes,
      _maxDurationMinutes,
    );
    setState(() {
      _adjustedMinutes = newMinutes;
    });
    _saveAdjustedMinutes(newMinutes);
  }

  void _decrementDuration() {
    final newMinutes = (_adjustedMinutes - _durationStep).clamp(
      _minDurationMinutes,
      _maxDurationMinutes,
    );
    setState(() {
      _adjustedMinutes = newMinutes;
    });
    _saveAdjustedMinutes(newMinutes);
  }

  void _showDescriptionSheet(BuildContext context, AppThemeData theme, TimerState timerState) {
    if (_sheetOpen) return;
    _sheetOpen = true;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DescriptionSheet(
        theme: theme,
        sessionStart: timerState.sessionStart ?? DateTime.now(),
        endedAt: timerState.endAt ?? _ringStartedAt ?? DateTime.now(),
        initialDescription: timerState.prefillDescription,
        initialActivityType: timerState.prefillActivityType,
        triggeredByStop: timerState.logTrigger == LogTrigger.stop,
      ),
    ).whenComplete(() {
      _sheetOpen = false;
    });
  }

  void _showPrefillSheet(BuildContext context, AppThemeData theme, TimerState timerState) {
    if (_sheetOpen) return;
    _sheetOpen = true;

    final notifier = ref.read(timerProvider.notifier);
    if (timerState.status == TimerStatus.running) {
      notifier.pause();
    }

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DescriptionSheet(
        theme: theme,
        sessionStart: timerState.sessionStart ?? DateTime.now(),
        endedAt: DateTime.now(),
        initialDescription: timerState.prefillDescription,
        initialActivityType: timerState.prefillActivityType,
        isPrefillMode: true,
      ),
    ).whenComplete(() {
      _sheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    ref.listen<TimerState>(timerProvider, (prev, next) {
      if (prev?.status != TimerStatus.ringing && next.status == TimerStatus.ringing) {
        _ringStartedAt = DateTime.now();
      }
      if (prev?.status != TimerStatus.logging && next.status == TimerStatus.logging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showDescriptionSheet(context, theme, next);
        });
      }
    });

    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final status = timerState.status;

    final isIdle = status == TimerStatus.idle;
    final isRinging = status == TimerStatus.ringing;

    final displaySeconds = isIdle ? _adjustedMinutes * 60 : timerState.secondsLeft;
    final totalSeconds = isIdle ? _adjustedMinutes * 60 : timerState.totalSeconds;
    final progress = totalSeconds > 0 ? displaySeconds / totalSeconds : 1.0;

    final minutes = displaySeconds ~/ 60;
    final seconds = displaySeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [ThemeDots()],
                // ),
                const Spacer(),

                // Ring + countdown
                SizedBox(
                  width: 288,
                  height: 288,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(288, 288),
                        painter: RingPainter(
                          progress: progress.clamp(0.0, 1.0),
                          theme: theme,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeText,
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: theme.text,
                              letterSpacing: -2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Phase label
                Text(
                  _phaseLabel(status),
                  style: TextStyle(
                    color: theme.dim,
                    fontFamily: 'Sora',
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 32),

                // Duration adjuster (idle only)
                if (isIdle) ...[
                  DurationAdjuster(
                    minutes: _adjustedMinutes,
                    onIncrement: _incrementDuration,
                    onDecrement: _decrementDuration,
                    min: _minDurationMinutes,
                    max: _maxDurationMinutes,
                    theme: theme,
                  ),
                  const SizedBox(height: 24),
                ] else
                  const SizedBox(height: 48 + 24),

                // Controls
                TimerControls(theme: theme, adjustedMinutes: _adjustedMinutes),

                if (status == TimerStatus.running || status == TimerStatus.paused) ...[
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => _showPrefillSheet(context, theme, timerState),
                    icon: Icon(Icons.edit_note_rounded, color: theme.dim),
                    tooltip: 'Pre-fill description',
                  ),
                ],

                const Spacer(),
              ],
            ),
          ),
        ),

        // Ringing overlay (on top of everything)
        if (isRinging)
          Positioned.fill(
            child: RingingOverlay(
              theme: theme,
              onDismiss: notifier.dismissRinging,
            ),
          ),
      ],
    );
  }

  String _phaseLabel(TimerStatus status) {
    switch (status) {
      case TimerStatus.idle:
        return 'READY';
      case TimerStatus.running:
        return 'FOCUS';
      case TimerStatus.paused:
        return 'PAUSED';
      case TimerStatus.ringing:
        return 'TIME UP';
      case TimerStatus.logging:
        return 'LOGGING';
    }
  }
}
