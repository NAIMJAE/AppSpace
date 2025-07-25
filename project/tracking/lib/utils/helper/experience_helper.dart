import 'package:tracking/utils/condition_config.dart';

class ExperienceHelper {
  /// 경험치 계산
  /// 거리 (m), 시간 (s), 속도 (m/s)
  static int experienceCalculation(int time, double distance, double speed) {
    double base = distance * 0.1; // 1km = 100 EXP
    double factor = 1.0;

    // 속력에 따른 가중치 계산
    if (speed < 1.0) {
      factor = 0.5; // 너무 느리면 감점
    } else if (speed > 3.5 && speed < 5.5) {
      factor = 1.2; // 걷기
    } else if (speed >= 5.5) {
      factor = 1.5; // 뛰기
    }

    // 10분 미만이면 감점
    double penalty = time < 600 ? 0.8 : 1.0;

    double exp = base * factor * penalty;
    return exp.round();
  }

  /// 레벨업 체크
  static int checkLevelUp(int level, int exp) {
    // 시작은 1레벨, expList[index] = index+1 레벨을 달성하기 위한 경험치
    final List<int> expList = expConfig;

    if (level >= expList.length) return level;

    for (int i = level; i < expList.length; i++) {
      if (exp < expList[i]) {
        return i;
      }
    }

    return expList.length;
  }
}
