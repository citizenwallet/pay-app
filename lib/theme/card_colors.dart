import 'package:flutter/cupertino.dart';
import 'package:pay_app/theme/colors.dart';

Color projectCardColor(String? project) {
  if (project == null) {
    return primaryColor;
  }

  switch (project) {
    case 'class':
      return Color(0xFFec6825);
    case 'smile':
      return Color(0xFF449197);
    default:
      return primaryColor;
  }
}
