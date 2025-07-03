import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../presentation/utils/riverpod_framework.dart';

part 'cache_service.g.dart';

// 이 구조는 이미지 캐시 용량을 관리하거나, 로그아웃 후 캐시 초기화 등에 매우 유용하게 쓰일 수 있습니다.

@Riverpod(keepAlive: true) // 앱이 해당 provider를 구독하지 않아도 메모리에 유지합니다.
CacheService cacheService(Ref ref) {
  return CacheService(
    customCacheManager: CacheManager(
      Config(
        'customCacheKey', // 캐시 키 이름
        maxNrOfCacheObjects: 100, // 최대 캐 파일 수
        stalePeriod: const Duration(days: 30), // 30일 지나면 캐시 만료
      ),
    ),
  );
}

class CacheService {
  const CacheService({
    required this.customCacheManager,
  });

  final CacheManager customCacheManager;

  Future<void> clearCustomCache() async {
    await customCacheManager.emptyCache();
  }

  Future<void> clearAllCache() async {
    await customCacheManager.emptyCache();
    //These clear app's live cache not global or stored cache
    imageCache.clear(); // Flutter 내부 이미지 캐시 삭제
    imageCache.clearLiveImages(); // 화면에 표시 중인 이미지 캐시도 삭제
  }

  Future<void> removeFileFromCache(String cacheKey) async {
    await customCacheManager.removeFile(cacheKey);
  }
}
