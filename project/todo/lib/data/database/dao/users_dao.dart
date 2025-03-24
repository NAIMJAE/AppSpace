import 'package:todo/data/database/database_helper.dart';
import 'package:todo/data/models/users_model/user.dart';

class UsersDao {
  // user 확인
  Future<bool> checkUserProfile() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // users 생성
  Future<int> insertUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('users', user.toMap());
  }

  // users 조회
  Future<List<User>> selectUser() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  // users 수정
}
