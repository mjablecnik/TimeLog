import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import 'edit_sheet.dart';

class HistoryEntryCard extends ConsumerStatefulWidget {
  final TimeEntry entry;
  final AppThemeData theme;

  const HistoryEntryCard({
    super.key,
    required this.entry,
    required this.theme,
  });

  @override
  ConsumerState<HistoryEntryCard> createState() => _HistoryEntryCardState();
}

class _HistoryEntryCardState extends ConsumerState<HistoryEntryCard> {
  String? _deleteError;

  String _formatTime(String isoString) {
    final dt = DateTime.parse(isoString).toLocal();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDuration(String startIso, String endIso) {
    final start = DateTime.parse(startIso);
    final end = DateTime.parse(endIso);
    final totalMinutes = end.difference(start).inMinutes;
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  String _truncateDescription(String desc, {int maxLen = 50}) {
    if (desc.length <= maxLen) return desc;
    return '${desc.substring(0, maxLen)}...';
  }

  Future<void> _delete(BuildContext context) async {
    final theme = widget.theme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete entry?',
          style: TextStyle(
              color: theme.text, fontFamily: 'Sora', fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.dim, fontFamily: 'Sora'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                  color: Colors.red[400],
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final dbService = ref.read(databaseServiceProvider).valueOrNull;
      if (dbService == null) {
        if (mounted) setState(() => _deleteError = 'Database unavailable.');
        return;
      }
      await dbService.deleteEntry(widget.entry.id);
    } catch (_) {
      if (mounted) {
        setState(() => _deleteError = 'Failed to delete entry.');
      }
    }
  }

  void _edit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditSheet(
        theme: widget.theme,
        entry: widget.entry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final theme = widget.theme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatTime(entry.startTime)} – ${_formatTime(entry.endTime)}',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.accent,
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  final color = activityTypeColor(
                    entry.activityType,
                    isDark: theme.themeKey != AppTheme.paper,
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      entry.activityType,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(entry.startTime, entry.endTime),
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: theme.dim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _truncateDescription(entry.description),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              color: theme.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_deleteError != null) ...[
            const SizedBox(height: 6),
            Text(
              _deleteError!,
              style: TextStyle(
                color: Colors.red[400],
                fontFamily: 'Sora',
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _edit(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18, color: theme.dim),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _delete(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 18, color: theme.dim),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
