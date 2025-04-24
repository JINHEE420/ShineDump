// import 'package:firebase_auth/firebase_auth.dart' as f_auth;
import 'package:freezed_annotation/freezed_annotation.dart';

import 'move_status.dart';

part 'moving_state.freezed.dart';
part 'moving_state.g.dart';

@freezed
class MovingState with _$MovingState {
  const factory MovingState({
    required double lat,
    required double long,
    required MoveStatus state,
    @Default(50.0) double radius,
    @Default(false) bool isDone,
    @Default(false) bool isNotified,
  }) = _MovingState;

  const MovingState._();

  factory MovingState.fromJson(Map<String, dynamic> json) =>
      _$MovingStateFromJson(json);
}
