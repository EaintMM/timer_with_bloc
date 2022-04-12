part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

// to inform TimerBlocs that the timer started
class TimerStarted extends TimerEvent {
  const TimerStarted({required this.duration});
  final int duration;
}

// to inform TimerBloc that the timer is paused
class TimerPaused extends TimerEvent {
  const TimerPaused();
}

// to inform TimerBloc that the timer is resumed
class TimerResumed extends TimerEvent {
  const TimerResumed();
}

// to inform TimerBloc that the timer is reset
class TimerReset extends TimerEvent {
  const TimerReset();
}

// to inform TimerBloc that the time is in progess and need to update accordingly
class TimerTicked extends TimerEvent {
  const TimerTicked({required this.duration});
  final int duration;

  @override
  List<Object> get props => [duration];
}
