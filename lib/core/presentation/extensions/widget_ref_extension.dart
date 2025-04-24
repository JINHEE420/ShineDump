part of '../utils/riverpod_framework.dart';

extension WidgetRefExtension on WidgetRef {
  // 해당 AsyncValue<T> 프로바이더가 지금 로딩 중인지를 bool로 즉시 돌려줍니다.
  // 어떻게 동작하나? : provider.select((s) => s.isLoading) → AsyncValue 전체가 아니라 isLoading 플래그만 골라서(select) 구독
  bool isLoading<T>(ProviderListenable<AsyncValue<T>> provider) {
    return watch(provider.select((AsyncValue<T> s) => s.isLoading));
  }

  /// Listen to a provider while easy handling Loading/Error dialogs.
  ///
  /// You can set handleLoading/handleError to false to turn off auto handling for either of them.
  ///
  /// Use `whenData` If you want to perform something when the newState is data.
  void easyListen<T>(
    // 이 메소드는 무엇을 하나?
    // 1. 로딩 시작 시 자동으로 로딩 다이얼로그를 띄우고
    // 2. 로딩 끝나면(prev 가 loading이었으면) 자동으로 다이얼로그 닫고
    // 3. 에러가 나면 에러 다이얼로그 띄우고
    // 4. 정상 데이터가 들어오면 whenData(data) 콜백 실행
    // 이 메소드를 언제 쓰나?
    // * 로딩·에러 처리 코드를 매번 반복하기 싫을 때
    // * 앱 전반에서 일관된 다이얼로그 UX를 보장하고 싶을 때
    ProviderListenable<AsyncValue<T>> provider, {
    bool handleLoading = true,
    bool handleError = true,
    void Function(T data)? whenData,
  }) {
    return listen(
      provider,
      (prevState, newState) {
        // 1) prevState.loading 일 때 다이얼로그 닫기
        prevState?.whenOrNull(
          skipLoadingOnRefresh:
              false, // skipLoadingOnRefresh: false 옵션 덕분에, 리프레시(refresh) 모드에서도 항상 실행
          loading:
              handleLoading ? () => NavigationService.popDialog(context) : null,
        );
        // 2) newState에 따라
        // handleLoading/handleError 플래그로 다이얼로그 자동 처리 켜고 끌 수 있음
        newState.whenOrNull(
          skipLoadingOnRefresh: false,
          loading:
              handleLoading ? () => Dialogs.showLoadingDialog(context) : null,
          error: handleError && context.mounted
              ? (err, st) => Dialogs.showErrorDialog(
                    context,
                    message: err.errorMessage(context),
                  )
              : null,
          data: whenData,
        );
      },
    );
  }

  /// Keep listening to [AutoDisposeNotifierProvider] until a Future function is complete.
  ///
  /// This method should be called asynchronously, like inside an onPressed.
  /// It shouldn't be used directly inside the build method.
  ///
  /// This is primarily used to initialize and preserve the state of the provider
  /// when navigating to a route until that route is popped off.
  ///
  /// Note: for Navigator 2.0 use "AutoDisposeRefExtension.keepAliveUntilNoListeners"

  Future<void> listenWhile<NotifierT extends AutoDisposeNotifier<T>, T>(
    // AutoDisposeNotifierProvider를 비동기 작업 수행 중(예: 버튼 눌렀을 때)
    // 한시적으로 구독(subscribe) 상태로 유지했다가, 작업이 끝나면 자동으로 구독을 해제(close)해 줍니다.
    AutoDisposeNotifierProvider<NotifierT, T> provider,
    Future<void> Function(NotifierT notifier) cb,
  ) async {
    //listenManual로 직접 구독을 걸어 두고
    // cb 콜백(예: await notifier.fetchData())을 실행
    // 끝나면 sub.close()로 자동 해제
    // 왜 필요하냐? AutoDisposeNotifier는 구독자가 하나도 없으면(state를) 자동 정리(autoDispose) 되도록 설계되어 있습니다.
    final sub = listenManual(provider, (_, __) {});
    try {
      return await cb(read(provider.notifier));
    } finally {
      sub.close();
    }
  }
}
// 이페이지 정리 isLoading → 로딩 상태 체크를 한 줄로
// easyListen → 로딩/에러 다이얼로그 + 데이터 콜백을 자동화
// listenWhile → AutoDisposeNotifier의 상태 유지를 간편히
