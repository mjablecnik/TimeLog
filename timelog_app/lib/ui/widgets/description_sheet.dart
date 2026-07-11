import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/timer_provider.dart';

const _activityTypes = ['Práce', 'Volný čas', 'Odpočinek', 'Spánek'];
const _lastActivityTypeKey = 'last_activity_type';

class DescriptionSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final DateTime sessionStart;
  final DateTime endedAt;

  const DescriptionSheet({
    super.key,
    required this.theme,
    required this.sessionStart,
    required this.endedAt,
  });

  @override
  ConsumerState<DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends ConsumerState<DescriptionSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;
  String _selectedType = _activityTypes.first;

  @override
  void initState() {
    super.initState();
    _loadLastActivityType();
  }

  Future<void> _loadLastActivityType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastActivityTypeKey);
    if (saved != null && _activityTypes.contains(saved) && mounted) {
      setState(() => _selectedType = saved);
    }
  }

  Future<void> _selectType(String type) async {
    setState(() => _selectedType = type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityTypeKey, type);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty && !_saving;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final dbService = ref.read(databaseServiceProvider).valueOrNull;
      if (dbService == null) {
        setState(() {
          _error = 'Database unavailable. Please try again.';
          _saving = false;
        });
        return;
      }

      await dbService.insertTimeEntry(
        TimeEntriesCompanion(
          startTime: Value(widget.sessionStart.toIso8601String()),
          endTime: Value(widget.endedAt.toIso8601String()),
          description: Value(_controller.text.trim()),
          activityType: Value(_selectedType),
        ),
      );

      ref.read(timerProvider.notifier).autoRestart();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = 'Failed to save entry. Please try again.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: theme.border)),
        ),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dim,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'What did you accomplish?',
                    style: TextStyle(
                      color: theme.text,
                      fontFamily: 'Sora',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _activityTypes.map((type) {
                      final isSelected = type == _selectedType;
                      return GestureDetector(
                        onTap: () => _selectType(type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.accent : theme.panel,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? theme.accent : theme.border,
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? theme.ink : theme.text,
                              fontFamily: 'Sora',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      maxLength: 500,
                      autofocus: true,
                      style: TextStyle(color: theme.text, fontFamily: 'Sora', fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Describe what you worked on...',
                        hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
                        border: InputBorder.none,
                        counterStyle: TextStyle(color: theme.faint, fontSize: 11),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red[400],
                        fontFamily: 'Sora',
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: theme.ink,
                        disabledBackgroundColor: theme.accent.withValues(alpha: 0.3),
                        disabledForegroundColor: theme.ink.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: theme.ink,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Submit',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: theme.ink,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
