import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracking/data/models/recode.dart';
import 'package:tracking/data/models/recode_group.dart';
import 'package:tracking/data/models/tracking.dart';
import 'package:tracking/data/models/tracking_state.dart';
import 'package:tracking/data/view_models/tracking_view_model.dart';
import 'package:tracking/ui/pages/tracking_page/widgets/tracking_info_box.dart';
import 'package:tracking/ui/widgets/dialog/confirm_dialog.dart';
import 'package:tracking/ui/widgets/google_map_widget.dart';
import 'package:tracking/utils/helper/distance_helper.dart';
import 'package:tracking/utils/helper/time_helper.dart';
import 'package:tracking/utils/location/location_service.dart';

class TrackingPage extends ConsumerStatefulWidget {
  final int selectedIndex;
  const TrackingPage({required this.selectedIndex, super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  late final TrackingViewModel trackingVM;
  bool isReady = false;
  bool isTrophy = false;
  bool isLevelUp = false;
  late Timer _timer;
  int _secondsPassed = 0;
  late RecodeGroup _recodeGroup;

  // 테스트용
  List<Tracking> testList = [
    Tracking(
        latitude: 35.160826,
        longitude: 129.057615,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.160873,
        longitude: 129.057490,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.160920,
        longitude: 129.057365,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.160970,
        longitude: 129.057235,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161020,
        longitude: 129.057100,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161065,
        longitude: 129.056970,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161110,
        longitude: 129.056840,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161155,
        longitude: 129.056710,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161200,
        longitude: 129.056580,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161245,
        longitude: 129.056450,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161290,
        longitude: 129.056320,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161335,
        longitude: 129.056190,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161380,
        longitude: 129.056060,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161425,
        longitude: 129.055930,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161470,
        longitude: 129.055800,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161515,
        longitude: 129.055670,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161560,
        longitude: 129.055540,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161605,
        longitude: 129.055410,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161650,
        longitude: 129.055280,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161695,
        longitude: 129.055150,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161740,
        longitude: 129.055020,
        time: DateTime.now(),
        distance: 0,
        verification: true),
    Tracking(
        latitude: 35.161785,
        longitude: 129.054890,
        time: DateTime.now(),
        distance: 0,
        verification: true),
  ];

  @override
  void initState() {
    super.initState();

    trackingVM = ref.read(trackingProvider.notifier);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TrackingPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (ref.read(trackingProvider).isTracking == 0 &&
        widget.selectedIndex == 1) {
      getCurrentLocation();
    }
  }

  /// 타이머 시작
  void _startTimer() {
    _secondsPassed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsPassed++;
      });
    });
  }

  /// 타이머 종료
  void _stopTimer() {
    _timer.cancel();
  }

  /// 타이머 포맷
  String get formattedTime {
    final duration = Duration(seconds: _secondsPassed);
    return duration.toString().split('.').first.padLeft(8, "0"); // hh:mm:ss
  }

  /// Tracking 시작
  /// startTracking - startForInterval - getPosition 수정
  /// 10초 주기 - [3m / 30km/h]
  /// 5초 주기 - [1.5m / 28km/h]
  /// 3초 주기 - [1m / 25km/h]
  void startTracking() async {
    if (!isReady) {
      return;
    }
    // 시작 시간 업데이트
    DateTime startTime = DateTime.now();
    _startTimer();

    trackingVM.startTracking(time: startTime);
    setState(() {});
    await Future.delayed(const Duration(seconds: 5));
    // 위치 정보 추적 시작
    await LocationService.startForInterval(
      onPosition: (position) {
        trackingVM.getPosition(position: position);
        setState(() {});
      },
    );

    // 테스트용
    // for (final tracking in testList) {
    //   Position position = Position(
    //     longitude: tracking.longitude,
    //     latitude: tracking.latitude,
    //     timestamp: DateTime.now(),
    //     accuracy: 5.0, // ⭐ 오차 5m
    //     altitude: 30.0, // ⭐ 고도 30m
    //     altitudeAccuracy: 3.0, // ⭐ 고도 정확도 3m
    //     heading: 90.0, // ⭐ 동쪽 방향
    //     headingAccuracy: 10.0, // ⭐ 방향 오차 10도
    //     speed: 1.5, // ⭐ 1.5m/s 걷기
    //     speedAccuracy: 0.5, // ⭐ 속도 오차 0.5m/s
    //   );
    //
    //   trackingVM.getPosition(position: position);
    //   setState(() {});
    //
    //   await Future.delayed(const Duration(seconds: 5));
    // }
  }

  /// Tracking 종료
  void endTracking() async {
    final shouldEnd = await ConfirmDialog.show(
      context,
      message: '트래킹을 종료하시겠습니까?',
    );

    if (shouldEnd) {
      _stopTimer();
      await LocationService.stopForInterval();

      RecodeGroup? result =
          await trackingVM.endTracking(endTime: DateTime.now());

      if (result != null) {
        _recodeGroup = result;
        trackingVM.changeTrackingState(value: 3);
        // _recodeGroup에서 레벨 트로피 변화 있으면 추가 작업
        if (_recodeGroup.trophy!.isNotEmpty) {
          setState(() {
            isTrophy = true;
          });
          await Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                isTrophy = false;
              });
            }
          });
        }
        // level 뭔가 잘못됨
        if (_recodeGroup.level != null) {
          setState(() {
            isLevelUp = true;
          });
          await Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                isLevelUp = false;
              });
            }
          });
        }
      } else {
        trackingVM.changeTrackingState(value: 4);
      }

      setState(() {});
    }
  }

  void showBanner(VoidCallback setter) {
    setter();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          setter();
        });
      }
    });
  }

  /// 현재 위치 정보 가져오기
  void getCurrentLocation() async {
    setState(() {
      isReady = false;
    });

    Position? position = await LocationService.getCurrentLocation();
    trackingVM.addStartPosition(position: position);

    setState(() {
      isReady = true;
    });
  }

  /// reset
  void _resetTracking() {
    isReady = false;
    _secondsPassed = 0;
    _recodeGroup = RecodeGroup(recode: Recode.empty(), detailList: []);
    _timer.cancel();
    trackingVM.resetTracking();
    getCurrentLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    TrackingState trackingState = ref.watch(trackingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      //backgroundColor: const Color(0XFF192028),
      // appBar: AppBar(
      //   title: Text('Tracking'),
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            GoogleMapWidget(
              trackingList: trackingState.trackingList,
            ),
            // loading 대기
            if (!isReady)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            if (trackingState.isTracking == 0)
              Positioned(
                bottom: 0,
                child: _readyBox(),
              ),

            if (trackingState.isTracking == 1)
              Positioned(
                bottom: 0,
                child: _trackingBox(state: trackingState),
              ),

            if (trackingState.isTracking == 2)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            if (trackingState.isTracking == 3)
              Positioned(
                bottom: 0,
                child: _completedBox(state: trackingState),
              ),

            if (trackingState.isTracking == 3 && isTrophy)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...List.generate(
                        _recodeGroup.trophy!.length,
                        (index) => Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.asset(
                                  'assets/images/trophies/${_recodeGroup.trophy?[index].trophyId}_get.png'),
                            ),
                            Text('${_recodeGroup.trophy?[index].name}')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (trackingState.isTracking == 3 && isLevelUp)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text('레벨업'),
                      Text('${_recodeGroup.level}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // isTracking == 0
  Widget _readyBox() {
    return TrackingInfoBox(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isReady) {
                getCurrentLocation();
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: isReady ? Colors.white : Colors.grey,
              ),
              child: Center(
                child: Text(
                  '위치 새로고침',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () {
              if (isReady) {
                startTracking();
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: isReady ? Colors.white : Colors.grey,
              ),
              child: Center(
                child: Text(
                  '시작',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // isTracking == 1
  Widget _trackingBox({required TrackingState state}) {
    return TrackingInfoBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              trackingInfoBox(
                title: '시간',
                information: formattedTime,
                unit: null,
              ),
              trackingInfoBox(
                title: '거리',
                information:
                    DistanceHelper.distanceFormatting(state.totalDistance),
                unit: state.totalDistance >= 1000 ? 'Km' : 'm',
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              trackingInfoBox(
                title: '속도',
                information: state.avgSpeed.toStringAsFixed(2),
                unit: 'km/h',
              ),
              trackingInfoBox(
                title: '칼로리',
                information: '0',
                unit: 'Kcal',
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: () => endTracking(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: isReady ? Colors.white : Colors.grey,
              ),
              child: Center(
                child: Text(
                  '종료',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // isTracking == 3
  // trackingState.trackingRecode 조건 추가하기???
  Widget _completedBox({required TrackingState state}) {
    return TrackingInfoBox(
      child: Column(
        children: [
          // 트래킹 제목 수정할 수 있게 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              trackingInfoBox(
                title: '시간',
                information: TimeHelper.transferTimeIntToString(
                    _recodeGroup.recode.time),
                unit: null,
              ),
              trackingInfoBox(
                title: '거리',
                information: DistanceHelper.distanceFormatting(
                    _recodeGroup.recode.distance),
                unit: state.totalDistance >= 1000 ? 'Km' : 'm',
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              trackingInfoBox(
                title: '속도',
                information: _recodeGroup.recode.speed.toStringAsFixed(2),
                unit: 'km/h',
              ),
              trackingInfoBox(
                title: '칼로리',
                information: '0',
                unit: 'Kcal',
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              trackingInfoBox(
                title: '경험치',
                information: _recodeGroup.recode.exp.toString(),
                unit: 'exp',
              ),
              // 여기 트로피
            ],
          ),

          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: () {
              if (isReady) {
                _resetTracking();
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: isReady ? Colors.white : Colors.grey,
              ),
              child: Center(
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget trackingInfoBox(
      {required String title,
      required String information,
      required String? unit}) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 4),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  information,
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                if (unit != null) const SizedBox(width: 2),
                if (unit != null)
                  Text(
                    unit,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
