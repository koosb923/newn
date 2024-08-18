import 'package:flutter/material.dart';

Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor"; // 알파 값이 없는 경우 FF(불투명)로 설정
  }
  return Color(int.parse(hexColor, radix: 16));
}
