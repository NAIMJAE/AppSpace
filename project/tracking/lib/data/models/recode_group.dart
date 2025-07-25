import 'package:tracking/data/models/recode.dart';
import 'package:tracking/data/models/recode_detail.dart';
import 'package:tracking/data/models/trophy.dart';

class RecodeGroup {
  final Recode recode;
  final List<RecodeDetail> detailList;
  List<Trophy>? trophy;
  int? level;

  RecodeGroup({
    required this.recode,
    required this.detailList,
    this.trophy,
    this.level,
  });

  void addRecode({required Recode recode}) {
    recode = recode;
  }

  void addTrophyAndLevel({required List<Trophy> trophy, required int level}) {
    this.trophy = trophy;
    this.level = level;
  }
}
