import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracking/data/models/trophy.dart';
import 'package:tracking/data/models/trophy_room.dart';
import 'package:tracking/data/models/user_info.dart';
import 'package:tracking/data/view_models/user_info_view_model.dart';
import 'package:tracking/utils/condition_config.dart';
import 'package:tracking/utils/helper/distance_helper.dart';
import 'package:tracking/utils/helper/time_helper.dart';
import 'package:tracking/utils/logger.dart';

class TrophyPage extends ConsumerStatefulWidget {
  const TrophyPage({super.key});

  @override
  ConsumerState<TrophyPage> createState() => _TrophyPageState();
}

class _TrophyPageState extends ConsumerState<TrophyPage> {
  final List<int> expList = expConfig;
  final Map<String, List<Trophy>> trophyMap = trophyCondition;

  @override
  Widget build(BuildContext context) {
    UserInfo userInfo = ref.watch(userInfoProvider);

    logger.i(userInfo.userExp.toString());
    double expRatio =
        180 * userInfo.userExp!.exp / expList[userInfo.userExp!.level];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Trophy'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _userInfoBox(userInfo: userInfo, expRatio: expRatio),
              const SizedBox(height: 8),
              ...trophyMap.entries.map(
                (e) {
                  final key = e.key;
                  final trophyList = e.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(key, style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...List.generate(
                              trophyList.length,
                              (index) {
                                Trophy trophy = trophyList[index];
                                TrophyRoom? userTrophy =
                                    userInfo.userTrophy[trophy.trophyId];
                                return SizedBox(
                                  width: 100,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: userTrophy != null
                                            ? Image.asset(
                                                'assets/images/trophies/${trophy.trophyId}_get.png')
                                            : Image.asset(
                                                'assets/images/trophies/${trophy.trophyId}.png'),
                                      ),
                                      Text('${trophy.name}')
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfoBox({required UserInfo userInfo, required double expRatio}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(70)),
              child: Image.asset('assets/images/profile/user_profile.jpg'),
            ),
          ),
          SizedBox(
            width: 180,
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '홍길동',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${userInfo.userExp?.level}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text('Lv'),
                          ],
                        ),
                        Text(
                          '${userInfo.userExp?.exp}/${expList[userInfo.userExp!.level]} exp',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 180,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        Container(
                          width: expRatio,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${DistanceHelper.distanceFormatting(userInfo.userExp!.distance)}',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                            '${userInfo.userExp!.distance >= 1000 ? 'Km' : 'm'}'),
                      ],
                    ),
                    Text(
                      '${TimeHelper.transferTimeIntToString(userInfo.userExp!.time)}',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
