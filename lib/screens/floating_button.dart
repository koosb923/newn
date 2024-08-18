import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double width; // 버튼의 가로 크기
  final double height; // 버튼의 세로 크기
  final double iconSize; // 아이콘 크기
  final Color backgroundColor; // 라운드 버튼 배경색
  final Color iconColor; // 아이콘 색상
  final double topLeftRadius; // 좌측 상단 라운드 반경
  final double topRightRadius; // 우측 상단 라운드 반경
  final double bottomLeftRadius; // 좌측 하단 라운드 반경
  final double bottomRightRadius; // 우측 하단 라운드 반경

  FloatingButton({
    required this.onPressed,
    this.width = 18.0, // 기본 가로 크기
    this.height = 86.0, // 기본 세로 크기
    this.iconSize = 18.0, // 기본 아이콘 크기
    this.backgroundColor = const Color.fromARGB(155, 16, 16, 16), // 기본 배경색
    this.iconColor = Colors.white, // 기본 아이콘 색상
    this.topLeftRadius = 0.0, // 기본 좌측 상단 라운드 반경
    this.topRightRadius = 12.0, // 기본 우측 상단 라운드 반경
    this.bottomLeftRadius = 0.0, // 기본 좌측 하단 라운드 반경
    this.bottomRightRadius = 12.0, // 기본 우측 하단 라운드 반경
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // 버튼 전체에 클릭 이벤트 적용
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius),
            topRight: Radius.circular(topRightRadius),
            bottomLeft: Radius.circular(bottomLeftRadius),
            bottomRight: Radius.circular(bottomRightRadius),
          ),
        ),
        child: Center(
          child: Icon(Icons.menu, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}