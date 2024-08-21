import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SiteConfig {
  final String url;
  final String buttonText;
  final String scriptUrl;
  final Color backgroundColor;
  final Color shadowColor;
  final bool injectScript;
  final String iconUrl;

  SiteConfig({
    required this.url,
    required this.buttonText,
    required this.scriptUrl,
    required this.backgroundColor,
    required this.shadowColor,
    required this.injectScript,
    required this.iconUrl,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      url: json['url'],
      buttonText: json['button_text'],
      scriptUrl: json['script_url'],
      backgroundColor: _getColorFromHex(json['background_color']),
      shadowColor: _getColorFromHex(json['shadow_color']),
      injectScript: json['inject_script'],
      iconUrl: json['icon'],
    );
  }

  static Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}

List<SiteConfig> siteConfigs = [];

Future<void> loadSiteConfigs() async {
  try {
    print('loadSiteConfigs 함수 시작');

    final response =
        await http.get(Uri.parse('https://newn.pages.dev/config/sites.json'));
    print('HTTP 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200) {
      String responseBody = response.body;
      print('서버로부터 받은 응답: $responseBody');

      List<dynamic> jsonList = json.decode(responseBody);
      print('JSON 파싱 성공, 데이터 크기: ${jsonList.length}');

      if (jsonList.isEmpty) {
        throw Exception('사이트 설정 데이터가 비어 있습니다.');
      }

      // JSON 데이터를 SiteConfig 객체로 변환
      siteConfigs = jsonList.map((json) => SiteConfig.fromJson(json)).toList();
      print("사이트 설정 불러오기 성공: ${siteConfigs.length}");

      // 각 사이트 설정에 대해 필요한 추가 초기화 로직을 여기에서 수행 가능
      // 예: 각 사이트의 아이콘을 미리 다운로드하는 작업 등
    } else {
      print('사이트 설정 파일 불러오기 실패: 상태 코드 ${response.statusCode}');
      throw Exception('사이트 설정 파일 불러오기 실패: 상태 코드 ${response.statusCode}');
    }
  } catch (e) {
    print('사이트 설정 불러오기 중 오류 발생: $e');
    throw Exception('사이트 설정 불러오기 실패: $e');
  } finally {
    print('loadSiteConfigs 함수 끝');
  }
}
