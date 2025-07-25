import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracking/data/database/dao/experience_dao.dart';
import 'package:tracking/data/models/user_info.dart';

class UserInfoViewModel extends Notifier<UserInfo> {
  final ExperienceDao _expDao = ExperienceDao();

  @override
  UserInfo build() {
    loadUserInfo();
    return UserInfo(userExp: null, userTrophy: {});
  }

  Future<void> loadUserInfo() async {
    state = await _expDao.selectUserInfo();
  }
}

final userInfoProvider = NotifierProvider<UserInfoViewModel, UserInfo>(
  () => UserInfoViewModel(),
);
