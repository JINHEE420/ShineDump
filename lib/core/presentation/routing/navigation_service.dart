import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

abstract class NavigationService {
  // 예를 들어, 텍스트 필드에서 “완료”를 눌렀을 때 키보드가 자동으로 내려가게 하고 싶으면 이 메서드를 호출하세요
  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void _closeOverlays() {
    // 토스트를 띄운 뒤 뒤로 가기나 화면 전환 시, 기존 토스트가 남아있지 않게 할 때 사용합니다.
    // 화면에 떠 있는 FlutterToast 토스트 메시지를 모두 제거합니다.
    FToast().removeQueuedCustomToasts();
  }

  static Future<void> pop<T>(
    // 화면을 닫고(previous route로 돌아감), 필요하면 토스트 등 오버레이를 먼저 정리합니다.
    // closeOverlays: true를 주면 _closeOverlays()를 호출한 뒤 context.pop()으로 실제 네비게이션 스택을 팝(popping) 합니다.
    // 내부적으로는 GoRouter의 context.pop()을 쓰므로, GoRouter로 정의한 라우트에서만 동작합니다.
    // 주석에 나와 있듯이, “다이얼로그 팝 vs 화면 팝”을 잘 구분하지 못하는 GoRouter 이슈가 있으니 유의해야 합니다.
    BuildContext context, {
    T? result,
    bool closeOverlays = false,
  }) async {
    if (closeOverlays) {
      _closeOverlays();
    }
    if (context.canPop()) {
      // Note: GoRouter logging will wrongly log that it's popping current route
      // when popping a dialog: https://github.com/flutter/flutter/issues/119237
      return context.pop(result);
    }
  }

  static Future<void> popDialog<T extends Object?>(
    // 다이얼로그만 닫고 싶을 때 씁니다.
    // rootNavigator: true를 사용하여 앱 전체 최상위 네비게이터에서 팝을 시도하기 때문에,
    // showDialog()로 띄운 팝업창을 확실히 닫아 줍니다.
    BuildContext context, {
    T? result,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      return navigator.pop(result);
    }
  }
}
