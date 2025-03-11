import 'package:calculator/data/models/calculation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class CalculationViewModel extends Notifier<List<List<Calculation>>> {
  List<Calculation> nowCalculation = [];
  String nowNumber = '0';
  double midNumber = 0;
  bool isNumber = true; // 숫자 차례 true, 연산자 차례 false
  bool nextStep = false; // '=' 입력 시 true

  @override
  List<List<Calculation>> build() {
    return [];
  }

  // 숫자 입력
  void addNumber({required int number}) {
    if (!isNumber) {
      nowNumber = '0';
      isNumber = true;
    }

    // 이전 연산이 끝났는지 확인
    if (nextStep) {
      nowCalculation.clear();
      nextStep = false;
    }

    // 0을 연속으로 입력할 수 없게 제한
    if (nowNumber == '0' && number == 0) {
      return;
    } else if (nowNumber == '0' && number != 0) {
      // 입력한 숫자가 0일때 다른 숫자를 입력하면 대체
      nowNumber = number.toString();
    } else {
      // 소수점 8자리 이하로 입력 제한
      List<String> numParts = nowNumber.split('.');
      if (numParts.length > 1 && numParts[1].length >= 8) {
        return; // 소수점 이하 8자리 이상이면 입력 제한
      }

      // 정수 부분 최대 1조(1e12)로 제한
      if (double.tryParse(nowNumber + number.toString())! >= 1e12) {
        return;
      }
      nowNumber += number.toString();
    }
    isNumber = true;
  }

  // 숫자 삭제
  void deleteLastNumber() {
    if (nowNumber.isNotEmpty && isNumber) {
      nowNumber = nowNumber.substring(0, nowNumber.length - 1);
    }
    if (nowNumber.isEmpty) {
      nowNumber = '0';
    }
  }

  // 소숫점 입력
  void addPoint({required String newOperator}) {
    if (!isNumber || nowNumber.contains('.')) {
      return;
    }
    nowNumber += newOperator;
  }

  // 연산자 입력
  Future<void> addOperator({required String newOperator}) async {
    // 숫자 입력 차례 && 연산의 첫 번째인 경우
    if (!isNumber && nextStep) {
      _continueCalculation();
    }

    if (!isNumber) {
      return; // 이미 연산자가 입력된 경우
    }

    // 입력한 연산자가 '='인데 '=' 연산이 불가능 한 경우 필터링
    if (newOperator == '=') {
      if (nextStep) {
        return;
      }
      if (nowCalculation.length < 3 &&
          nowCalculation.last.type == 'operator' &&
          !isNumber) {
        return;
      }
    }

    // % 처리
    if (newOperator == '％') {
      nowNumber = _validatedNumber(checkNumber: (double.parse(nowNumber) / 100))
          .toString();
      return;
    }

    // ± 처리
    if (newOperator == '±') {
      nowNumber =
          removeTrailingZero(number: (double.parse(nowNumber) * -1).toString());
      return;
    }

    if (nowNumber.isNotEmpty) {
      Calculation number =
          Calculation(type: 'number', value: double.parse(nowNumber));
      nowCalculation.add(number);
      nowCalculation.add(Calculation(type: 'operator', value: newOperator));
    }

    await middleCalculation();
    isNumber = false;
  }

  // 중간 결과 계산
  Future<void> middleCalculation() async {
    if (nowCalculation.length < 3) {
      midNumber = double.parse(nowNumber);
      return;
    }

    double num1 = midNumber;
    double num2 = nowCalculation[nowCalculation.length - 2].value;
    Calculation lastOperator = nowCalculation[nowCalculation.length - 3];

    switch (lastOperator.value) {
      case '×':
        midNumber = num1 * num2;
        break;
      case '÷':
        if (num2 == 0) {
          nowNumber = '0으로 나눌 수 없음';
          nowCalculation.removeLast();
          nowCalculation.removeLast();
          return;
        }
        midNumber = num1 / num2;
        break;
      case '-':
        midNumber = num1 - num2;
        break;
      case '+':
        midNumber = num1 + num2;
        break;
    }
    // 무한대 방지
    if (midNumber.isNaN || midNumber.isInfinite) {
      nowNumber = "오류";
      return;
    }

    nowNumber = _validatedNumber(checkNumber: midNumber);
    // // 값이 1e12 이상이면 지수 표기법
    // if (midNumber.abs() >= 1e12) {
    //   nowNumber = midNumber.toStringAsExponential(6); // 6자리 유효 숫자로 변환
    // } else {
    //   // 소수점 8자리까지만 유지 + 불필요한 0 제거
    //   midNumber = double.parse(midNumber.toStringAsFixed(8));
    //   nowNumber = midNumber.toString();
    // }

    // 마지막 연산자가 '='인 경우
    if (nowCalculation.last.value == '=') {
      nowCalculation.add(Calculation(type: 'number', value: midNumber));
      state.insert(0, List.from(nowCalculation));
      nextStep = true;
    }
  }

  // 값이 유효한지 검증
  String _validatedNumber({required double checkNumber}) {
    // 값이 1e12 이상이면 지수 표기법
    if (checkNumber.abs() >= 1e12) {
      return checkNumber.toStringAsExponential(6); // 6자리 유효 숫자로 변환
    } else {
      // 소수점 8자리까지만 유지 + 불필요한 0 제거
      checkNumber = double.parse(checkNumber.toStringAsFixed(8));
      return checkNumber.toString();
    }
  }

  // 연속 계산
  void _continueCalculation() {
    Calculation lastNumber = nowCalculation.last;
    nowCalculation.clear();
    nowNumber = lastNumber.value.toString();
    midNumber = 0;
    isNumber = true;
    nextStep = false;
  }

  // 현재 계산식 초기화
  void clearCalculation() {
    nowCalculation.clear();
    nowNumber = '0';
    midNumber = 0;
    isNumber = true;
    nextStep = false;
  }

  // 출력 메서드들 //
  // 현재 입력 중인 숫자 출력
  String showNowNumber() {
    if (nowNumber == '0으로 나눌 수 없음') {
      return nowNumber;
    }
    return formatNumber(number: nowNumber);
  }

  // 현재 계산 중인 연산 기록 출력
  String showNowCalculator() {
    String showValue = '';
    for (int i = 0; i < nowCalculation.length; i++) {
      if (nowCalculation[i].type == 'operator') {
        showValue += ' ${nowCalculation[i].value.toString()} ';
      } else if (nowCalculation[i].value is num) {
        if (i > 0 && nowCalculation[i - 1].value == '=') {
          continue;
        }
        if (nowCalculation[i].value % 1 == 0) {
          showValue += nowCalculation[i].value.toInt().toString();
        } else {
          showValue += nowCalculation[i].value.toString();
        }
      }
    }
    return showValue;
  }

  // 전체 계산 기록 출력
  Tuple2<String, String> showCalculatorHistory(
      {required List<Calculation> calculation}) {
    String expression = '';
    String result = '';
    for (int i = 0; i < calculation.length; i++) {
      if (i > 0 && calculation[i - 1].value == '=') {
        String number = formatNumber(number: calculation[i].value.toString());
        result = removeTrailingZero(number: number);
        continue;
      }
      if (calculation[i].type == 'operator') {
        expression += ' ${calculation[i].value.toString()} ';
      } else {
        String number = formatNumber(number: calculation[i].value.toString());
        expression += removeTrailingZero(number: number);
      }
    }
    return Tuple2(expression, result);
  }

  // 화면 출력 숫자 포맷팅
  String formatNumber({required String number}) {
    String result;
    List<String> numArr = number.split('.');

    if (numArr.length < 2) {
      result = NumberFormat("#,##0").format(double.parse(number));
    } else {
      String numPart = NumberFormat("#,##0").format(double.parse(numArr[0]));
      numPart += '.${numArr[1]}';
      result = numPart;
    }

    if (!isNumber) {
      result = removeTrailingZero(number: result);
    }

    return result;
  }

  // .0 버리기
  String removeTrailingZero({required String number}) {
    if (number.endsWith('.0')) {
      return number.substring(0, number.length - 2);
    } else {
      return number;
    }
  }
}

final calculationProvider =
    NotifierProvider<CalculationViewModel, List<List<Calculation>>>(
  () => CalculationViewModel(),
);
