class Calculation {
  String type; // number, operator
  dynamic value;

  Calculation({required this.type, required this.value});

  void updatePercent() {
    value = value / 100;
  }

  @override
  String toString() {
    return 'Calculation{type: $type, value: $value}';
  }
}
