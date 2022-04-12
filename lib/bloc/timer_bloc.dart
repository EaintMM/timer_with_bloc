import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:timer_with_bloc/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  // Preset duration 1 minute
  static const int _duration = 60;
  final Ticker _ticker;

  // For the ticker streaming subscription
  StreamSubscription<int>? _tickerSubscription;

  // Initial state set up and event handlers registration
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerTicked>(_onTicked);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
  }

  // For [TimerStarted] event
  /// When the timer is started (TimerStarted event) , pushe [TimerRunInProgress] state.
  /// In case of [_tickerSubscription] already open, cancel it to deallocate memory.
  /// Listen to tick stream and change state by adding [TimerTicked] event for every tick.
  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  // For TimerTicked event
  /// When [TimerTicked] event , if duration is 0, push [TimerRunComplete] state, else  [TimerRunInProgress] state with update duration.
  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : TimerRunComplete(),
    );
  }

  // For TimerPaused
  /// When TimerPaused event, need to pause the tick stream and push [TimerRunPause] state with that duration.
  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  // For TimerResumed event
  /// The ticker stream (subscription) is resumed when [TimerResumed] event occurs and the current state is paused [TimerRunPause]
  /// Change state to [TimerRunInProgress] with the current state duration
  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  // For TimerReset event
  /// First the subscription is cancelled and reset duration to preset 1 minute (Going back to initial State [TimerInitial])
  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerInitial(_duration));
  }

  // override [close()] to be able to cancel the subscription(tick stream).
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
