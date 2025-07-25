import 'package:tracking/data/models/recode_detail.dart';
import 'package:tracking/data/models/tracking.dart';

class DistanceHelper {
  /// 거리 포맷팅
  static String distanceFormatting(double distance) {
    if (distance >= 1000) {
      return (distance / 1000).toStringAsFixed(2);
    }
    return distance.toStringAsFixed(2);
  }

  /// 구간별 기록 계산
  static List<RecodeDetail> intervalCalculation({
    required String recodeId,
    required DateTime time,
    required List<Tracking> list,
  }) {
    List<RecodeDetail> detailList = [];
    DateTime prevTime = time;
    double sumDist = 0;
    Duration sumTime = Duration.zero;

    for (var each in list) {
      if (each.verification) {
        Duration eachDuration = each.time.difference(prevTime).abs();

        // false 에서 prevTime 떄문에 오류 있을 것 같음
        if (sumDist + each.distance >= 500) {
          double restDist = sumDist + each.distance - 500;

          int useSec = (eachDuration.inSeconds *
                  (each.distance - restDist) /
                  each.distance)
              .round();
          Duration useDuration = Duration(seconds: useSec);

          double speed = double.parse(
              (sumDist / useDuration.inSeconds * 3.6).toStringAsFixed(2));

          detailList.add(
            RecodeDetail(
              detailId: RecodeDetail.createDetailId(),
              recodeId: recodeId,
              interval: 500 * (detailList.length + 1),
              distance: double.parse(sumDist.toStringAsFixed(2)),
              speed: speed,
              time: sumTime.inSeconds,
            ),
          );

          sumDist = restDist;
          sumTime = eachDuration - useDuration;
        } else {
          sumDist += each.distance;
          sumTime += eachDuration;
        }
        prevTime = each.time;
      }
    }

    if (sumDist != 0 && sumTime.inSeconds != 0) {
      double speed =
          double.parse((sumDist / sumTime.inSeconds * 3.6).toStringAsFixed(2));

      detailList.add(
        RecodeDetail(
          detailId: RecodeDetail.createDetailId(),
          recodeId: recodeId,
          interval: 500 * (detailList.length + 1),
          distance: double.parse(sumDist.toStringAsFixed(2)),
          speed: speed,
          time: sumTime.inSeconds,
        ),
      );
    }

    return detailList;
  }
}
