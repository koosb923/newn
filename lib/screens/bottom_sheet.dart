import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/site_config.dart';

void showCustomBottomSheet(
    BuildContext context, Function(String) switchWebView) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    backgroundColor: Colors.transparent, // 투명 배경을 사용하여 라운드가 보이도록 설정
    builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.white, // 바텀시트 전체 배경색을 흰색으로 설정
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: siteConfigs.map((config) {
              return ListTile(
                leading: Image.network(
                  config.iconUrl,
                  width: 24.0, // 아이콘 크기 변경
                  height: 24.0, // 아이콘 크기 변경
                ),
                title: Text(
                  config.buttonText,
                  style: TextStyle(
                    color: Colors.black, // 텍스트 색상을 검정색으로 적용
                    fontWeight: FontWeight.bold, // 폰트 두께 설정
                    fontFamily: 'NotoSansKR', // 한글 폰트 적용 (pubspec.yaml에 추가해야 함)
                  ),
                ),
                tileColor: Colors.white, // 리스트 항목의 배경색을 흰색으로 적용
                onTap: () {
                  print("Switching to: ${config.url}");
                  switchWebView(config.url);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      );
    },
  );
}
