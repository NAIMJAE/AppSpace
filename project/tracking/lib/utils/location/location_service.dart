import 'dart:async';
import 'package:flutter_background/flutter_background.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStream;

  /// 현재 위치 반복 조회 시작
  static Future<void> startForInterval({
    required void Function(Position) onPosition,
  }) async {
    // 1. 위치 권한 확인
    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      print('🚫 위치 권한 없음');
      return;
    }

    // 2. 백그라운드 실행 상태 확인
    if (!await FlutterBackground.isBackgroundExecutionEnabled) {
      // Android 전용 설정
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "위치 추적 중",
        notificationText: "앱이 백그라운드에서 위치를 추적 중입니다.",
        notificationImportance: AndroidNotificationImportance.normal,
      );

      // 3. 백그라운드 초기화
      final initialized =
          await FlutterBackground.initialize(androidConfig: androidConfig);
      if (!initialized) {
        print('🚫 FlutterBackground 초기화 실패');
        return;
      }

      // 4. 백그라운드 실행 활성화
      final enabled = await FlutterBackground.enableBackgroundExecution();
      if (!enabled) {
        print('🚫 백그라운드 실행 실패');
        return;
      }
      print('✅ 백그라운드 실행 활성화 완료');
    }

    // 5. 기존 위치 스트림이 있다면 중지
    if (_positionStream != null) {
      print('⚠️ 위치 스트림이 이미 활성화되어 있습니다. 기존 스트림 중지.');
      await stopForInterval();
    }

    // 6. 위치 스트림 시작
    _positionStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 5),
      ),
    ).listen((position) {
      print('📍 ${position.latitude}, ${position.longitude}');
      onPosition(position);
    });

    print('✅ 위치 추적 시작');
  }

  /// 위치 반복 조회 중단
  static Future<void> stopForInterval() async {
    try {
      await _positionStream?.cancel();
      _positionStream = null;

      if (await FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.disableBackgroundExecution();
        print('🛑 위치 추적 중지');
      } else {
        print('⚠️ 백그라운드 실행이 이미 비활성화 상태입니다.');
      }
    } catch (e) {
      print('❌ 위치 추적 중지 오류: $e');
    }
  }

  /// 현재 위치 1회 조회
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      print('📍 현재 위치: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ 현재 위치 가져오기 실패: $e');
      return null;
    }
  }

  /// 위치 권한 확인
  static Future<bool> _checkPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      print('🚫 위치 서비스 비활성화');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('🚫 위치 권한 거부됨');
        return false;
      }
    }

    print('✅ 위치 권한 확인 완료');
    return true;
  }
}
