import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracking/ui/pages/root_page.dart';

void main() async {
  runApp(ProviderScope(child: TrackingApp()));
}

class TrackingApp extends StatelessWidget {
  const TrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tracking',
      home: RootPage(),
    );
  }
}

/// 05.15 테스트 (12분 30초 동안 1.3km 이동)
/// 트래킹 후 확인 버튼 클릭시 isReady 계속 false
/// GPS 좌표 튀는 현상 발생 -> 살짝 뛰었을 때 발생 -> 내 로직이 제대로 처리하지 못한듯
/// 트로피 획득 화면에서 12시 방향에 트로피 나옴 + 배경색 더 짙게 해도 될듯
/// 대기 화면에서 위치 새로고침 시 새 위치가 화면에 반영되지 않는 문제 -> setState 누락 또는 같은 id값이라 갱신 안되는 것 같음
///
