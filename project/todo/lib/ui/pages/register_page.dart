import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/models/icon_model/icon_color.dart';
import 'package:todo/data/models/icon_model/icon_info.dart';
import 'package:todo/data/view_models/user_view_model.dart';
import 'package:todo/ui/pages/home_page/home_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  IconColor _selectedColor =
      IconColor(name: 'red', color: const Color(0xFFFF0000));
  IconInfo _selectedIcon = IconInfo(
      name: 'person_alt', iconData: CupertinoIcons.person_alt, type: 'profile');
  late UserViewModel _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = ref.read(userProvider.notifier);
  }

  void _startTodoBtn() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    bool success = await _userProvider.insertUser(
      name: name,
      icon: _selectedIcon.name,
      color: _selectedColor.name,
    );
    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필 생성에 실패했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF81C784), Color(0xFF4FC3F7)],
              //colors: [Color(0xFFB39DDB), Color(0xFF64B5F6)],
              begin: Alignment.topCenter, // 위에서 시작
              end: Alignment.bottomCenter, // 아래에서 끝
            ),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '안녕하세요.',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        'NAIMJAE가 만든 TODO 앱입니다.',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '프로필을 생성하고 일정 관리를 시작하세요!',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _createProfile(),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom / 10)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createProfile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _profileBox(),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: TextField(
            onChanged: (value) => setState(() {}),
            controller: _nameController,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1),
              ),
              fillColor: Colors.transparent,
              labelText: '이름',
              labelStyle: TextStyle(color: Colors.white),
              counterStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _selectIconBox(),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: FilledButton(
            onPressed: () => _startTodoBtn(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              elevation: 3,
            ),
            child: const Text(
              '시작하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _profileBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _selectedIcon.iconData,
                color: _selectedColor.color,
                shadows: [
                  Shadow(
                    color: Colors.grey,
                    blurRadius: 2,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Text(
                _nameController.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectIconBox() {
    return Column(
      children: [
        _colorBox(),
        const SizedBox(height: 8),
        _IconBox(),
      ],
    );
  }

  Widget _IconBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 3 / 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
            profileIconList.length,
            (index) {
              List<IconInfo> iconList = profileIconList[index];
              return Row(
                children: [
                  ...List.generate(
                    iconList.length,
                    (index) => _eachIcon(iconInfo: iconList[index]),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _colorBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          iconColorList.length,
          (index) => _eachColor(iconColor: iconColorList[index]),
        )
      ],
    );
  }

  Widget _eachColor({required IconColor iconColor}) {
    return GestureDetector(
      onTap: () {
        _selectedColor = iconColor;
        setState(() {});
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(2),
            width: MediaQuery.of(context).size.width * 3 / 4 / 7 - 4,
            height: MediaQuery.of(context).size.width * 3 / 4 / 7 - 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: iconColor.color,
            ),
          ),
          if (_selectedColor.color == iconColor.color)
            Icon(
              Icons.check,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.grey,
                  blurRadius: 2,
                  offset: Offset(1, 2),
                ),
              ],
              size: MediaQuery.of(context).size.width * 3 / 4 / 7,
            ),
        ],
      ),
    );
  }

  Widget _eachIcon({required IconInfo iconInfo}) {
    return GestureDetector(
      onTap: () {
        _selectedIcon = iconInfo;
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 3 / 4 / 5,
            height: MediaQuery.of(context).size.width * 3 / 4 / 5,
            child:
                Icon(iconInfo.iconData, color: _selectedColor.color, shadows: [
              Shadow(
                color: Colors.grey,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ]),
          ),
          if (_selectedIcon.iconData == iconInfo.iconData)
            Container(
              width: MediaQuery.of(context).size.width * 3 / 4 / 7,
              height: MediaQuery.of(context).size.width * 3 / 4 / 7,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
