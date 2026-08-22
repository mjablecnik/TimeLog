import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/timer_provider.dart';
import '../../services/timer_service.dart';

class TimerControls extends ConsumerWidget {
  final AppThemeData theme;
  final int adjustedMinutes;

  const TimerControls({
    super.key,
    required this.theme,
    required this.adjustedMinutes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final status = timerState.status;

    final isIdle = status == TimerStatus.idle;
    final isRunning = status == TimerStatus.running;
    final isPaused = status == TimerStatus.paused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          size: 52,
          icon: Icons.stop_rounded,
          enabled: isRunning || isPaused,
          theme: theme,
          onPressed: () => _stopWithConfirmation(context, notifier),
          isAccent: false,
        ),
        const SizedBox(width: 20),
        _CircleButton(
          size: 80,
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          enabled: true,
          theme: theme,
          onPressed: () {
            if (isIdle) {
              notifier.setDuration(adjustedMinutes);
              notifier.start();
            } else if (isRunning) {
              notifier.pause();
            } else if (isPaused) {
              notifier.resume();
            }
          },
          isAccent: true,
        ),
        const SizedBox(width: 20),
        _CircleButton(
          size: 52,
          icon: Icons.flag_rounded,
          enabled: isRunning || isPaused,
          theme: theme,
          onPressed: notifier.finishNow,
          isAccent: false,
        ),
      ],
    );
  }

  Future<void> _stopWithConfirmation(BuildContext context, TimerNotifier notifier) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.timerResetTitle,
          style: TextStyle(
              color: theme.text, fontFamily: 'Sora', fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.timerResetBody,
          style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: theme.dim, fontFamily: 'Sora'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.commonReset,
              style: TextStyle(
                  color: Colors.red[400],
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      notifier.stopAndLog();
    }
  }
}

class _CircleButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final bool enabled;
  final AppThemeData theme;
  final VoidCallback onPressed;
  final bool isAccent;

  const _CircleButton({
    required this.size,
    required this.icon,
    required this.enabled,
    required this.theme,
    required this.onPressed,
    required this.isAccent,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled;
    final bgColor = isAccent && active ? theme.accent : theme.panel;
    final iconColor = isAccent && active
        ? theme.ink
        : active
            ? theme.text
            : theme.faint;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: theme.border),
        boxShadow: isAccent && active
            ? [BoxShadow(color: theme.glow, blurRadius: 16, spreadRadius: 2)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: active ? onPressed : null,
          child: Icon(icon, color: iconColor, size: size * 0.44),
        ),
      ),
    );
  }
}
