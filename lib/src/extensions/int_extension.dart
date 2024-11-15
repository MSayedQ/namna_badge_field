import 'package:flutter/material.dart';

extension IntExtension on int? {
  int validate({int value = 0}) {
    return this ?? value;
  }

  Widget get spaceH => SizedBox(height: this?.toDouble());
  Widget get spaceW => SizedBox(width: this?.toDouble());
}
