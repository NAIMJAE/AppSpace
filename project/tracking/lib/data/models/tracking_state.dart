import 'package:tracking/data/models/recode_group.dart';
import 'package:tracking/data/models/tracking.dart';

class TrackingState {
  int isTracking; // 0:ready | 1:tracking | 2:waiting | 3:complete | 4:error
  DateTime? startTime;
  double totalDistance;
  double avgSpeed;
  List<Tracking> trackingList;
  List<Tracking> waitingList;

  TrackingState({
    required this.isTracking,
    required this.startTime,
    required this.totalDistance,
    required this.avgSpeed,
    required this.trackingList,
    required this.waitingList,
  });

  /// TrackingState 정보 업데이트
  void updateTrackingState({required double distance}) {
    totalDistance += double.parse(distance.toStringAsFixed(2));
    avgSpeed = double.parse(_getAvgSpeed().toStringAsFixed(2));
  }

  /// 평균 속도 계산
  double _getAvgSpeed() {
    final int seconds = DateTime.now().difference(startTime!).inSeconds;
    double speed = seconds > 0 ? totalDistance / seconds : 0;
    final double speedKmH = speed * 3.6;
    return speedKmH;
  }

  /// Tracking 상태 변경
  void changeTrackingState({required int state}) {
    isTracking = state;
  }

  /// Tracking 시작 시간 기록
  void updateStartTime({required DateTime time}) {
    startTime = time;
  }

  /// trackingList 초기화 후 추가
  void resetAndAddTrackingList({required Tracking tracking}) {
    trackingList = [tracking]; // 새로운 리스트로 덮어쓰기
  }

  /// trackingList 추가
  void addTrackingList({required Tracking tracking}) {
    trackingList = [...trackingList, tracking]; // 기존 + 새 트래킹 → 새 리스트 생성
  }

  /// 이전 Tracking 정보 반환
  Tracking getLastTracking() {
    for (int i = trackingList.length - 1; i >= 0; i--) {
      if (trackingList[i].verification) {
        return trackingList[i];
      }
    }
    return trackingList[0];
  }
}
