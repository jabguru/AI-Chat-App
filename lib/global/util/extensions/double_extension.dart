extension DoubleFormat on double {
  double percent(double percent) => this * percent / 100;
  String get intOrDouble {
    if (this == truncate()) {
      return toInt().toString();
    }
    return toStringAsFixed(2);
  }
}
