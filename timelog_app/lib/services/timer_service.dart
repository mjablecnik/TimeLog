import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import 'alarm_service.dart';
import 'live_activity_channel.dart';

part 'timer_service.freezed.dart';

enum TimerStatus { idle, running, paused, ringing, logging }

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerStatus status,
    required int totalSeconds,
    required int secondsLeft,
    DateTime? sessionStart,
    DateTime? endAt,
  }) = _TimerState;
}

const _kTimerStatus = 'timer_status';
const _kTimerEndAt = 'timer_endAt';
const _kTimerSessionStart = 'timer_sessionStart';
const _kTimerTotalSeconds = 'timer_totalSeconds';
const _kTimerSecondsLeft = 'timer_secondsLeft';

class TimerNotifier extends StateNotifier<TimerState> with WidgetsBindingObserver {
  Timer? _ticker;
  final AlarmService _alarm;
  final LiveActivityChannel _liveActivity;

  TimerNotifier(this._alarm, this._liveActivity)
      : super(TimerState(
          status: TimerStatus.idle,
          totalSeconds: TimerConfig.defaultDurationMinutes * 60,
          secondsLeft: TimerConfig.defaultDurationMinutes * 60,
        )) {
    WidgetsBinding.instance.addObserver(this);
    _liveActivity.setLockScreenActionHandler(_handleLockScreenAction);
    _restoreState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recalculate();
    }
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final statusStr = prefs.getString(_kTimerStatus);
    if (statusStr == null) return;

    final totalSeconds =
        prefs.getInt(_kTimerTotalSeconds) ?? (TimerConfig.defaultDurationMinutes * 60);
    final secondsLeftSaved = prefs.getInt(_kTimerSecondsLeft) ?? totalSeconds;
    final sessionStartMs = prefs.getInt(_kTimerSessionStart);
    final endAtMs = prefs.getInt(_kTimerEndAt);

    final sessionStart = sessionStartMs != null
        ? DateTime.fromMillisecondsSinceEpoch(sessionStartMs)
        : null;
    final savedEndAt =
        endAtMs != null ? DateTime.fromMillisecondsSinceEpoch(endAtMs) : null;

    if (statusStr == TimerStatus.running.name && savedEndAt != null) {
      final secondsLeft = savedEndAt.difference(DateTime.now()).inSeconds;
      if (secondsLeft <= 0) {
        state = TimerState(
          status: TimerStatus.ringing,
          totalSeconds: totalSeconds,
          secondsLeft: 0,
          sessionStart: sessionStart,
          endAt: null,
        );
        _alarm.play();
        _saveState();
      } else {
        state = TimerState(
          status: TimerStatus.running,
          totalSeconds: totalSeconds,
          secondsLeft: secondsLeft,
          sessionStart: sessionStart,
          endAt: savedEndAt,
        );
        _startTicker();
      }
    } else if (statusStr == TimerStatus.paused.name) {
      state = TimerState(
        status: TimerStatus.paused,
        totalSeconds: totalSeconds,
        secondsLeft: secondsLeftSaved,
        sessionStart: sessionStart,
        endAt: null,
      );
    } else if (statusStr == TimerStatus.ringing.name) {
      state = TimerState(
        status: TimerStatus.ringing,
        totalSeconds: totalSeconds,
        secondsLeft: 0,
        sessionStart: sessionStart,
        endAt: null,
      );
      _alarm.play();
    }
  }

  void _saveState() {
    final s = state;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_kTimerStatus, s.status.name);
      prefs.setInt(_kTimerTotalSeconds, s.totalSeconds);
      prefs.setInt(_kTimerSecondsLeft, s.secondsLeft);
      if (s.sessionStart != null) {
        prefs.setInt(_kTimerSessionStart, s.sessionStart!.millisecondsSinceEpoch);
      } else {
        prefs.remove(_kTimerSessionStart);
      }
      if (s.endAt != null) {
        prefs.setInt(_kTimerEndAt, s.endAt!.millisecondsSinceEpoch);
      } else {
        prefs.remove(_kTimerEndAt);
      }
    });
  }

  void _clearPersistedState() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_kTimerStatus);
      prefs.remove(_kTimerEndAt);
      prefs.remove(_kTimerSessionStart);
      prefs.remove(_kTimerTotalSeconds);
      prefs.remove(_kTimerSecondsLeft);
    });
  }

  void start() {
    if (state.status != TimerStatus.idle) return;
    final now = DateTime.now();
    final endAt = now.add(Duration(seconds: state.secondsLeft));
    state = state.copyWith(
      status: TimerStatus.running,
      sessionStart: now,
      endAt: endAt,
    );
    _startTicker();
    _saveState();
    _liveActivity.startActivity(endAt: endAt, totalSeconds: state.totalSeconds);
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(
      status: TimerStatus.paused,
      endAt: null,
    );
    _saveState();
    _liveActivity.updateActivity(update: LiveActivityUpdate.paused);
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;
    final endAt = DateTime.now().add(Duration(seconds: state.secondsLeft));
    state = state.copyWith(
      status: TimerStatus.running,
      endAt: endAt,
    );
    _startTicker();
    _saveState();
    _liveActivity.updateActivity(update: LiveActivityUpdate.resumed);
  }

  void setDuration(int minutes) {
    if (state.status != TimerStatus.idle) return;
    final seconds = (minutes * 60).clamp(60, 86400);
    state = state.copyWith(totalSeconds: seconds, secondsLeft: seconds);
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _alarm.stop();
    _liveActivity.endActivity();
    state = TimerState(
      status: TimerStatus.idle,
      totalSeconds: state.totalSeconds,
      secondsLeft: state.totalSeconds,
    );
    _clearPersistedState();
  }

  void finishNow() {
    if (state.status != TimerStatus.running && state.status != TimerStatus.paused) return;
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(
      status: TimerStatus.ringing,
      secondsLeft: 0,
      endAt: null,
    );
    _saveState();
    _alarm.play();
    _liveActivity.updateActivity(update: LiveActivityUpdate.completed);
  }

  void dismissRinging() {
    if (state.status != TimerStatus.ringing) return;
    _alarm.stop();
    _liveActivity.endActivity();
    state = state.copyWith(status: TimerStatus.logging);
    // Keep persisted state as 'ringing' so if app is killed during logging,
    // next launch shows ringing state again for the user to dismiss.
  }

  void autoRestart() {
    final now = DateTime.now();
    final totalSeconds = state.totalSeconds;
    final endAt = now.add(Duration(seconds: totalSeconds));
    state = TimerState(
      status: TimerStatus.running,
      totalSeconds: totalSeconds,
      secondsLeft: totalSeconds,
      sessionStart: now,
      endAt: endAt,
    );
    _startTicker();
    _saveState();
    _liveActivity.startActivity(endAt: endAt, totalSeconds: totalSeconds);
  }

  void _handleLockScreenAction(String action) {
    switch (action) {
      case 'pause':
        pause();
      case 'resume':
        resume();
      case 'stop':
        stop();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _recalculate());
  }

  void _recalculate() {
    if (state.status != TimerStatus.running) return;
    final endAt = state.endAt;
    if (endAt == null) return;
    final secondsLeft = endAt.difference(DateTime.now()).inSeconds;
    if (secondsLeft <= 0) {
      _ticker?.cancel();
      _ticker = null;
      state = state.copyWith(
        status: TimerStatus.ringing,
        secondsLeft: 0,
        endAt: null,
      );
      _saveState();
      _alarm.play();
      _liveActivity.updateActivity(update: LiveActivityUpdate.completed);
    } else {
      state = state.copyWith(secondsLeft: secondsLeft);
    }
  }
}
