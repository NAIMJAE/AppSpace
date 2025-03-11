import 'package:calculator/data/models/calculation.dart';
import 'package:calculator/data/view_models/calculation_view_model.dart';
import 'package:calculator/data/view_models/theme_view_model.dart';
import 'package:calculator/ui/widgets/main_appbar.dart';
import 'package:calculator/ui/widgets/operator_button.dart';
import 'package:calculator/ui/widgets/number_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late final CalculationViewModel calculationVM;
  late final ThemeViewModel themeStateVM;
  bool isHistory = false;
  bool isSetting = false;
  List<List<dynamic>> btnList = [
    ['AC', '±', '％', '÷'],
    [7, 8, 9, '×'],
    [4, 5, 6, '-'],
    [1, 2, 3, '+'],
    [0, '.', '='],
  ];

  @override
  void initState() {
    super.initState();
    calculationVM = ref.read(calculationProvider.notifier);
    themeStateVM = ref.read(themeProvider.notifier);
  }

  // 숫자 버튼 클릭
  void clickNumberButton({required int number}) {
    calculationVM.addNumber(number: number);
    setState(() {});
  }

  // 연산자 버튼 클릭
  void clickOperatorButton({required String newOperator}) {
    if (newOperator == 'AC') {
      calculationVM.clearCalculation();
      setState(() {});
      return;
    }

    if (newOperator == '.') {
      calculationVM.addPoint(newOperator: newOperator);
      setState(() {});
      return;
    }

    calculationVM.addOperator(newOperator: newOperator);
    setState(() {});
  }

  // 전체 계산 기록 보이기
  void showCalculationHistory() {
    isHistory = !isHistory;
    setState(() {});
  }

  // 전체 계산 기록 보이기
  void showSetting() {
    isSetting = !isSetting;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double cntWidth = MediaQuery.of(context).size.width;
    double normalBtn = (cntWidth - 16) / 4 - 8;
    double longBtn = ((cntWidth - 16) / 4 - 8) * 2 + 8;
    double startPosition = 0; // 스와이프 시작 위치 저장

    final themeState = ref.watch(themeProvider);
    List<List<Calculation>> calList = ref.watch(calculationProvider);

    return themeState.when(
      data: (themeState) => Scaffold(
        backgroundColor: themeState.backgroundColor,
        appBar: mainAppbar(
            context: context,
            themeState: themeState,
            showHistory: showCalculationHistory,
            showSetting: showSetting),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 출력 화면
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque, // 빈 공간에서도 터치 감지

                        onHorizontalDragStart: (details) {
                          startPosition =
                              details.localPosition.dx; // 터치 시작 지점 저장
                        },

                        onHorizontalDragEnd: (details) {
                          double endPosition =
                              details.velocity.pixelsPerSecond.dx; // 터치 종료 지점
                          double moveDistance =
                              endPosition - startPosition; // 움직인 거리 계산

                          // 오른쪽으로 일정 거리 이상 이동하면 삭제
                          if (moveDistance > 50) {
                            setState(() {
                              calculationVM.deleteLastNumber();
                            });
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                calculationVM.showNowCalculator(),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: themeState.displayColor),
                                textAlign: TextAlign.end,
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown, // 크기를 자동으로 줄여줌
                                child: Text(
                                  calculationVM.showNowNumber(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    color: themeState.displayColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 계산기 버튼
                  ...List.generate(
                    btnList.length,
                    (index) {
                      List<dynamic> btnRow = btnList[index];
                      return Row(
                        children: [
                          ...List.generate(
                            btnRow.length,
                            (index) => btnRow[index] is num
                                ? btnRow[index] == 0
                                    ? NumButton(
                                        number: btnRow[index],
                                        width: longBtn,
                                        height: normalBtn,
                                        textColor: themeState.numberColor,
                                        btnColor: themeState.numberBtnColor,
                                        function: (val) =>
                                            clickNumberButton(number: val),
                                      )
                                    : NumButton(
                                        number: btnRow[index],
                                        width: normalBtn,
                                        height: normalBtn,
                                        textColor: themeState.numberColor,
                                        btnColor: themeState.numberBtnColor,
                                        function: (val) =>
                                            clickNumberButton(number: val),
                                      )
                                : ['AC', '±', '％'].contains(btnRow[index])
                                    ? CalButton(
                                        operator: btnRow[index],
                                        width: normalBtn,
                                        height: normalBtn,
                                        textColor: themeState.operatorColor,
                                        btnColor: themeState.controlBtnColor,
                                        function: (val) => clickOperatorButton(
                                            newOperator: val),
                                      )
                                    : btnRow[index] == '.'
                                        ? CalButton(
                                            operator: btnRow[index],
                                            width: normalBtn,
                                            height: normalBtn,
                                            textColor: themeState.numberColor,
                                            btnColor: themeState.numberBtnColor,
                                            function: (val) =>
                                                clickOperatorButton(
                                                    newOperator: val),
                                          )
                                        : CalButton(
                                            operator: btnRow[index],
                                            width: normalBtn,
                                            height: normalBtn,
                                            textColor: themeState.operatorColor,
                                            btnColor:
                                                themeState.operatorBtnColor,
                                            function: (val) =>
                                                clickOperatorButton(
                                                    newOperator: val),
                                          ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // 전체 계산 기록 토글
            if (isHistory)
              Positioned(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isHistory || isSetting) {
                          setState(() {
                            isHistory = false;
                            isSetting = false;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: cntWidth,
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                            color: themeState.numberBtnColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeState.displayColor,
                                blurRadius: 4,
                                spreadRadius: -2,
                                offset: Offset(0, -2),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 32, left: 20, right: 20, bottom: 12),
                          child: ListView(
                            children: [
                              ...List.generate(
                                calList.length,
                                (index) => historyBox(
                                  calculation: calList[index],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            if (isSetting)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE9E9E9),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            themeStateVM.setTheme(mode: 'Light');
                            isSetting = !isSetting;
                            setState(() {});
                          },
                          child: const Text('Light',
                              style: TextStyle(fontSize: 16)),
                        ),
                        InkWell(
                          onTap: () {
                            themeStateVM.setTheme(mode: 'Dark');
                            isSetting = !isSetting;
                            setState(() {});
                          },
                          child: const Text('Dark',
                              style: TextStyle(fontSize: 16)),
                        ),
                        InkWell(
                          onTap: () {
                            themeStateVM.setTheme(mode: 'Colorful');
                            isSetting = !isSetting;
                            setState(() {});
                          },
                          child: const Text('Colorful',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
      loading: () => Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()), // 로딩 화면 표시
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('오류 발생: $error')),
      ),
    );
  }

  Widget historyBox({required List<Calculation> calculation}) {
    final themeState = ref.watch(themeProvider);
    var history = calculationVM.showCalculatorHistory(calculation: calculation);
    return themeState.when(
      data: (themeState) => Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    history.item1,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeState.displayColor.withOpacity(0.6),
                    ),
                    softWrap: true,
                    textAlign: TextAlign.end,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown, // 크기를 자동으로 줄여줌
                    child: Text(
                      history.item2,
                      style: TextStyle(
                          fontSize: 32,
                          color: themeState.displayColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()), // 로딩 화면 표시
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('오류 발생: $error')),
      ),
    );
  }
}
