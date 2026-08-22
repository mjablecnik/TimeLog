import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../l10n/generated/app_localizations.dart';

class RingingOverlay extends StatefulWidget {
  final AppThemeData theme;
  final VoidCallback onDismiss;

  const RingingOverlay({super.key, required this.theme, required this.onDismiss});

  @override
  State<RingingOverlay> createState() => _RingingOverlayState();
}

class _RingingOverlayState extends State<RingingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 16, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.background.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.accent,
                    boxShadow: [
                      BoxShadow(
                        color: theme.glow,
                        blurRadius: _glow.value,
                        spreadRadius: _glow.value * 0.2,
                      ),
                    ],
                  ),
                  transform: Matrix4.diagonal3Values(
                    _scale.value,
                    _scale.value,
                    1,
                  )..translateByDouble(-60 * (_scale.value - 1), -60 * (_scale.value - 1), 0, 0),
                  child: Icon(Icons.alarm_rounded, color: theme.ink, size: 56),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.timerTimeUpTitle,
              style: TextStyle(
                color: theme.text,
                fontFamily: 'Sora',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.panel,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: theme.border),
                ),
                child: Text(
                  l10n.ringingDismiss,
                  style: TextStyle(
                    color: theme.text,
                    fontFamily: 'Sora',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
