import 'package:flutter/foundation.dart';

enum MoveStatus { moving, loading, unloading }

extension ConvertToString on MoveStatus {
  String display() {
    switch (this) {
      case MoveStatus.loading:
        return kDebugMode ? 'Arrived at loading point' : '상차지에 도착했습니다';
      case MoveStatus.unloading:
        return kDebugMode ? 'Arrived at unloading point' : '하차지에 도착했습니다';
      case MoveStatus.moving:
        return kDebugMode ? 'Moving' : '운행이 진행중입니다';
    }
  }
}
