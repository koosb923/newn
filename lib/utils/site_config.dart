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
    required this.buttonText, // 버튼 텍스트 추가
    required this.scriptUrl,
    required this.backgroundColor,
    required this.shadowColor,
    required this.injectScript,
    required this.iconUrl,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      url: json['url'],
      buttonText: json['button_text'], // 버튼 텍스트 로드
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

List<SiteConfig> siteConfigs = []; // 여기에 실제 사이트 구성 데이터를 넣습니다.

Future<void> loadSiteConfigs() async {
  try {
    final response =
        await http.get(Uri.parse('https://newn.pages.dev/config/sites.json'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      siteConfigs = jsonList.map((json) => SiteConfig.fromJson(json)).toList();
      print('SiteConfigs loaded successfully.');
    } else {
      throw Exception('Failed to load site configs: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading site configs: $e');
  }
}
