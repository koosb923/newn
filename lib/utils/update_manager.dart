import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newn/utils/site_config.dart'; // site_config 파일을 import

class UpdateManager {
  String? lastUpdate;

  Future<void> checkForUpdates() async {
    SharedPreferences prefs;
    try {
      // SharedPreferences 인스턴스 가져오기
      prefs = await SharedPreferences.getInstance();

      // 로컬에 저장된 마지막 업데이트 날짜 가져오기
      lastUpdate = prefs.getString('last_update');
      print('UpdateManager: 로컬에 저장된 last_update: $lastUpdate');

      // 서버에서 업데이트 체크 파일 불러오기
      final response = await http
          .get(Uri.parse('https://newn.pages.dev/config/update_check.json'));

      if (response.statusCode == 200) {
        Map<String, dynamic> updateCheck = json.decode(response.body);
        String serverLastUpdate = updateCheck['last_update'];
        print('UpdateManager: 서버에서 받은 last_update: $serverLastUpdate');

        // 로컬에 저장된 last_update 값이 없거나, 서버의 날짜가 더 최신인 경우 업데이트
        if (lastUpdate == null ||
            DateTime.parse(serverLastUpdate)
                .isAfter(DateTime.parse(lastUpdate!))) {
          print('UpdateManager: 업데이트가 필요함. 사이트 설정 파일을 로드합니다.');

          // 업데이트가 필요하면 실제 데이터 파일을 가져오기
          await _loadSiteConfigsAndUpdate(prefs, serverLastUpdate);
        } else if (siteConfigs.isEmpty) {
          print('UpdateManager: 사이트 설정이 비어 있음. 강제로 사이트 설정을 불러옵니다.');
          // siteConfigs가 비어 있을 경우에만 강제로 사이트 설정을 다시 불러옴
          await _loadSiteConfigsAndUpdate(prefs, serverLastUpdate,
              forceUpdate: true);
        } else {
          print("UpdateManager: 업데이트가 필요하지 않음.");
        }
      } else {
        throw Exception('업데이트 체크 파일 불러오기 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('UpdateManager: 업데이트 체크 파일 불러오기 중 오류 발생: $e');
      if (lastUpdate != null && siteConfigs.isEmpty) {
        prefs = await SharedPreferences.getInstance(); // catch 블록 내에서 prefs 초기화
        print('UpdateManager: 네트워크 오류로 인한 사이트 설정 불러오기 시도');
        await _loadSiteConfigsAndUpdate(prefs, lastUpdate, forceUpdate: true);
      }
      throw Exception('업데이트 체크 파일 불러오기 실패: $e');
    }
  }

  Future<void> _loadSiteConfigsAndUpdate(
      SharedPreferences prefs, String? serverLastUpdate,
      {bool forceUpdate = false}) async {
    try {
      await loadSiteConfigs();
      print("UpdateManager: 사이트 설정 불러오기 성공: ${siteConfigs.length}");

      if (serverLastUpdate != null && !forceUpdate) {
        // 업데이트가 완료되면 마지막 업데이트 날짜를 로컬에 저장
        await prefs.setString('last_update', serverLastUpdate);
        print(
            'UpdateManager: 새로운 last_update 값이 로컬에 저장되었습니다: $serverLastUpdate');
      }
    } catch (e) {
      print('UpdateManager: 사이트 설정 불러오기 중 오류 발생: $e');
    }
  }
}
