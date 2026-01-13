import 'package:flutter/material.dart';

extension IntToTimeOfDay on int {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: this ~/ 60, minute: this % 60);
}

extension TimeOfDayToInt on TimeOfDay {
  int toInt() => 60 * hour + minute;
}
