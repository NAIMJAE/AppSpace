import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracking/data/database/dao/experience_dao.dart';
import 'package:tracking/data/database/dao/recode_dao.dart';
import 'package:tracking/data/models/experience.dart';
import 'package:tracking/data/models/recode.dart';
import 'package:tracking/data/models/recode_detail.dart';
import 'package:tracking/data/models/recode_group.dart';
import 'package:tracking/data/models/tracking.dart';
import 'package:tracking/data/models/tracking_state.dart';
import 'package:tracking/data/models/trophy.dart';
import 'package:tracking/data/view_models/history_view_model.dart';
import 'package:tracking/data/view_models/user_info_view_model.dart';
import 'package:tracking/utils/helper/distance_helper.dart';
import 'package:tracking/utils/helper/experience_helper.dart';
import 'package:tracking/utils/helper/time_helper.dart';
import 'package:tracking/utils/helper/trophy_helper.dart';
import 'package:tracking/utils/logger.dart';

class TrackingViewModel extends Notifier<TrackingState> {
  final RecodeDao _recodeDao = RecodeDao();
  final ExperienceDao _expDao = ExperienceDao();
  List<Tracking> abnormalList = [];

  @override
  TrackingState build() {
    return TrackingState(
      isTracking: 0,
      startTime: null,
      totalDistance: 0,
      avgSpeed: 0,
      trackingList: [],
      waitingList: [],
    );
  }

  /// 외부에서 접근 가능한 상태 변경 함수
  void changeTrackingState({required int value}) {
    state.changeTrackingState(state: value);
  }

  /// 시작 위치 업데이트
  /// - 트래킹 페이지 접근 & 위치 새로고침
  void addStartPosition({required Position? position}) {
    if (position != null) {
      Tracking tracking = Tracking(
        time: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        distance: 0,
        verification: true,
      );
      state.resetAndAddTrackingList(tracking: tracking);
    }
  }

  /// Tracking 시작
  /// - 트래킹 시작 버튼 클릭
  /// - 트래킹 상태 업데이트 & 트래킹 시작 시간 기록
  void startTracking({required DateTime time}) {
    state.changeTrackingState(state: 1);
    state.updateStartTime(time: time);
  }

  /// Tracking 시작 후 위치 정보 업데이트
  /// - 트래킹 시작 후 주기마다
  /// - 이동 거리, 이동 속도 계산 & 유효성 검사
  void getPosition({required Position position}) {
    DateTime now = DateTime.now();
    Tracking last = state.getLastTracking();

    // 이동 거리 계산
    final double distance = Geolocator.distanceBetween(
      last.latitude,
      last.longitude,
      position.latitude,
      position.longitude,
    );

    if (distance <= 1.5) {
      logger.e('[이동 거리 1.5m 이하] 이동 거리 : $distance');
      return;
    }

    // 이동 속도 계산
    final int seconds = now.difference(last.time).inSeconds;
    final double speed = distance / seconds;
    final double speedKmH = speed * 3.6;

    // 비정상적인 움직임 처리 (GPS 튐, 교통 수단 이용)
    if (speedKmH >= 25) {
      logger.e('[비정상적인 움직임] 이동 속도 : ${speedKmH.toStringAsFixed(2)} km/h');

      Tracking abnormal = Tracking(
        time: now,
        latitude: position.latitude,
        longitude: position.longitude,
        distance: distance,
        verification: false,
      );

      if (abnormalList.length < 4) {
        abnormalList.add(abnormal);
        return;
      }

      // 비정상 4번 이상이면 그대로 저장 - 미완성임
      for (final t in abnormalList) {
        state.addTrackingList(tracking: t);
      }
      abnormalList.clear();
      return;
    }

    // 새로운 Tracking 객체 생성
    Tracking tracking = Tracking(
      time: now,
      latitude: position.latitude,
      longitude: position.longitude,
      distance: distance,
      verification: true,
    );

    // 이전에 기록된 비정상적 움직임 보정
    if (abnormalList.isNotEmpty) {
      // 선형 보간에 사용될 간격 계산
      int abNum = abnormalList.length;
      double lastLat = last.latitude;
      double lastLng = last.longitude;

      double latGap = (tracking.latitude - lastLat) / (abNum + 1);
      double lngGap = (tracking.longitude - lastLng) / (abNum + 1);

      // 비정상 구간 좌표값 보정
      for (int i = 1; i <= abNum; i++) {
        double correctedLat =
            double.parse((last.latitude + (latGap * i)).toStringAsFixed(6));
        double correctedLng =
            double.parse((last.longitude + (lngGap * i)).toStringAsFixed(6));

        double segmentDistance = Geolocator.distanceBetween(
          lastLat,
          lastLng,
          correctedLat,
          correctedLng,
        );

        final correctedTracking = Tracking(
          time: abnormalList[i - 1].time,
          latitude: correctedLat,
          longitude: correctedLng,
          distance: segmentDistance,
          verification: true,
        );

        state.addTrackingList(tracking: correctedTracking);
        state.updateTrackingState(distance: segmentDistance);

        // 이전 보정 위치 갱신
        lastLat = correctedLat;
        lastLng = correctedLng;
      }

      abnormalList.clear();
    }
    // tracking 정보 업데이트 및 거리 합산
    state.addTrackingList(tracking: tracking);
    state.updateTrackingState(distance: distance);
  }

  /// Tracking 종료
  /// - 트래킹 종료 버튼 클릭
  /// - 트래킹 최종 결과 추출 & DB 저장
  Future<RecodeGroup?> endTracking({required DateTime endTime}) async {
    state.changeTrackingState(state: 2);
    // 칼로리, 지도 남음
    try {
      // 트래킹 데이터 정제 후 Recode 객체 생성
      Recode recode = _createRecode(endTime: endTime);

      // 구간별 기록 계산
      List<RecodeDetail> detailList = DistanceHelper.intervalCalculation(
        recodeId: recode.recodeId,
        time: recode.start,
        list: state.trackingList,
      );

      RecodeGroup recodeGroup =
          RecodeGroup(recode: recode, detailList: detailList);

      // 사용자 기록 최신화
      Experience? experience = await _experienceCheck(
        exp: recode.exp,
        distance: recode.distance,
        time: recode.time,
      );

      // 트로피 획득 여부 확인
      List<Trophy> nowTpy = [];
      if (experience != null) {
        nowTpy = await TrophyHelper.checkTrophy(
            experience.distance, experience.time);
        recodeGroup.addTrophyAndLevel(trophy: nowTpy, level: experience.level);
      }

      // DB 저장 (추후 사진 저장 추가 예정)
      await _recodeDao.processTrackingDataTransaction(
        recodeGroup: recodeGroup,
        experience: experience!,
        nowTpy: TrophyHelper.parseTrophyRoom(nowTpy),
      );

      ref.read(userInfoProvider.notifier).loadUserInfo();
      ref.read(historyProvider.notifier).loadRecodeHistory();

      return recodeGroup;
    } catch (e) {
      logger.e('ERROR :: ENDTRACKING EXCEPTION $e');
      return null;
    }
  }

  /// Tracking 데이터 정제 후 Recode 객체 반환
  Recode _createRecode({required DateTime endTime}) {
    double distance = state.totalDistance; // 총 이동 거리
    DateTime start = state.startTime!; // 트래킹 시작 시간
    DateTime date = DateTime(start.year, start.month, start.day); // 트래킹 일시
    int time =
        TimeHelper.validTimeCalculation(start, state.trackingList); // 총 이동 시간
    double avgSpeed = time > 0 ? (distance / time) * 3.6 : 0; // 평균 이동 속도 (m/s)
    int exp = ExperienceHelper.experienceCalculation(
        time, distance, avgSpeed); // 획득 경험치

    return Recode(
      recodeId: Recode.createRecodeId(),
      title: '${date.year}_${date.month}_${date.day} 트래킹',
      date: date,
      start: start,
      end: endTime,
      time: time,
      distance: distance,
      speed: avgSpeed,
      exp: exp,
    );
  }

  /// 사용자 총 Tracking 정보 update & Trophy 획득 여부 판단
  Future<Experience?> _experienceCheck(
      {required int exp, required double distance, required int time}) async {
    // 경험치 조회
    Experience? userExp = await _expDao.selectExperience();

    if (userExp != null) {
      userExp.updateExperience(
          newExp: exp, newDistance: distance, newTime: time);
      int nowLv = ExperienceHelper.checkLevelUp(userExp.level, userExp.exp);
      userExp.updateLevel(value: nowLv);
      return userExp;
    } else {
      throw Exception('ERROR :: NOT FOUND USER EXPERIENCE');
    }
  }

  /// reset
  void resetTracking() {
    abnormalList.clear();
    state = TrackingState(
      isTracking: 0,
      startTime: null,
      totalDistance: 0,
      avgSpeed: 0,
      trackingList: [],
      waitingList: [],
    );
  }
}

final trackingProvider = NotifierProvider<TrackingViewModel, TrackingState>(
  () => TrackingViewModel(),
);
