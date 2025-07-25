class Trophy {
  final String trophyId;
  final String name;
  final String description;
  final String conditionType;
  final double conditionValue;
  final int depth;

  Trophy({
    required this.trophyId,
    required this.name,
    required this.description,
    required this.conditionType,
    required this.conditionValue,
    required this.depth,
  });
}

// conditionValue - distance - 단위 m
// conditionValue - time - 단위 s
final Map<String, List<Trophy>> trophyCondition = {
  'distance': [
    Trophy(
        trophyId: 'TPYDIS0001',
        name: '초보 러너',
        description: '첫 1km를 달성한 러너',
        conditionType: 'distance',
        conditionValue: 1000, // 1km
        depth: 1),
    Trophy(
        trophyId: 'TPYDIS0002',
        name: '성장하는 러너',
        description: '누적 거리 5km를 달성한 러너',
        conditionType: 'distance',
        conditionValue: 5000, // 5km
        depth: 2),
    Trophy(
        trophyId: 'TPYDIS0003',
        name: '꾸준한 러너',
        description: '누적 거리 10km를 달성한 러너',
        conditionType: 'distance',
        conditionValue: 10000, // 10km
        depth: 3),
    Trophy(
        trophyId: 'TPYDIS0004',
        name: '지구력 러너',
        description: '누적 거리 50km를 달성한 러너',
        conditionType: 'distance',
        conditionValue: 50000, // 50km
        depth: 4),
    Trophy(
        trophyId: 'TPYDIS0005',
        name: '마스터 러너',
        description: '누적 거리 100km를 달성한 러너',
        conditionType: 'distance',
        conditionValue: 100000, // 100km
        depth: 5),
  ],
  'time': [
    Trophy(
        trophyId: 'TPYTIM0001',
        name: '시간의 도전자',
        description: '누적 시간 1시간을 달성한 러너',
        conditionType: 'time',
        conditionValue: 3600, // 1시간
        depth: 1),
    Trophy(
        trophyId: 'TPYTIM0002',
        name: '인내의 러너',
        description: '누적 시간 5시간을 달성한 러너',
        conditionType: 'time',
        conditionValue: 18000, // 5시간
        depth: 2),
    Trophy(
        trophyId: 'TPYTIM0003',
        name: '끈기의 러너',
        description: '누적 시간 10시간을 달성한 러너',
        conditionType: 'time',
        conditionValue: 36000, // 10시간
        depth: 3),
    Trophy(
        trophyId: 'TPYTIM0004',
        name: '지구력 챔피언',
        description: '누적 시간 50시간을 달성한 러너',
        conditionType: 'time',
        conditionValue: 180000, // 50시간
        depth: 4),
    Trophy(
        trophyId: 'TPYTIM0005',
        name: '철인 러너',
        description: '누적 시간 100시간을 달성한 러너',
        conditionType: 'time',
        conditionValue: 360000, // 100시간
        depth: 5),
  ],
};
