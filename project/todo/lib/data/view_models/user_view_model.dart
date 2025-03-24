import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/database/dao/users_dao.dart';
import 'package:todo/data/models/icon_model/icon_color.dart';
import 'package:todo/data/models/icon_model/icon_info.dart';
import 'package:todo/data/models/users_model/user.dart';

class UserViewModel extends Notifier<User?> {
  final UsersDao _usersDao = UsersDao();
  late IconColor iconColor;
  late IconInfo iconInfo;

  @override
  User? build() {
    return null;
  }

  /// 최초 로드시 유저 정보 불러오기
  /// - 근데 여기 시작할때 에러나서 수정해야함
  Future<void> loadUser() async {
    List<User> users = await _usersDao.selectUser();
    if (users.isEmpty) {
      return;
    }
    state = users[0];
    _mappingIconAndColor(color: users[0].color, icon: users[0].icon);
  }

  /// 사용자의 아이콘 찾기
  /// - 더 좋은 방법 없는지 고민해보기
  void _mappingIconAndColor({required String color, required String icon}) {
    iconColor = iconColorList.firstWhere((e) => e.name == color);
    iconInfo = profileIconList.expand((list) => list).firstWhere(
          (e) => e.name == icon,
          orElse: () =>
              IconInfo(name: 'default', iconData: Icons.error, type: 'profile'),
        );
  }

  /// 유저 정보 생성
  /// - 유저 정보를 데이터베이스에 생성 한후 state 업데이트
  /// @param
  /// - name : 사용자 이름
  /// - icon : 사용자 아이콘 이름
  /// - color : 사용자 아이콘 색상 이름
  /// @return
  /// - 유저 정보 생성 성공 여부 반환
  Future<bool> insertUser(
      {required String name,
      required String icon,
      required String color}) async {
    User newUser = User(id: 100001, name: name, icon: icon, color: color);
    int result = await _usersDao.insertUser(newUser);
    await loadUser();
    if (result > 0) {
      return true;
    } else {
      return false;
    }
  }
}

final userProvider = NotifierProvider<UserViewModel, User?>(
  () => UserViewModel(),
);
