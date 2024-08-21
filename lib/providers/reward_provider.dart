import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class RewardProvider with ChangeNotifier {
  int _rewards = 0; // 사용자의 포인트를 저장하는 변수
  bool _adsRemoved = false; // 광고 제거 여부를 나타내는 변수
  int _adsRemoveDaysLeft = 30; // 광고 제거 일수를 저장하는 변수

  // 포인트를 가져오는 getter
  int get rewards => _rewards;

  // 광고 제거 여부를 가져오는 getter
  bool get adsRemoved => _adsRemoved;

  // 광고 제거가 남은 일수를 가져오는 getter
  int get adsRemoveDaysLeft => _adsRemoveDaysLeft;

  // 생성자: 객체가 생성될 때 호출되며, 저장된 포인트와 광고 제거 상태를 로드하고, 자정에 광고 제거 일수를 업데이트하는 타이머를 설정함
  RewardProvider() {
    _loadRewards();
    _setNextMidnightTimer();
    _startPointTimer(); // 포인트를 1분마다 증가시키는 타이머 시작
  }

  // SharedPreferences를 사용해 저장된 포인트와 광고 제거 상태를 로드하는 함수
  void _loadRewards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rewards = prefs.getInt('rewards') ?? 0;
    _adsRemoved = prefs.getBool('adsRemoved') ?? false;
    _adsRemoveDaysLeft = prefs.getInt('adsRemoveDaysLeft') ?? 30;
    notifyListeners(); // UI에 상태가 변경되었음을 알림
  }

  // 매일 자정에 광고 제거 일수를 업데이트하는 타이머를 설정하는 함수
  void _setNextMidnightTimer() {
    DateTime now = DateTime.now(); // 현재 시간
    DateTime nextMidnight =
        DateTime(now.year, now.month, now.day + 1, 0, 0, 0); // 다음 자정 시간
    Duration timeUntilMidnight = nextMidnight.difference(now); // 자정까지 남은 시간 계산

    // 자정이 되면 광고 제거 일수 감소를 실행하고, 다음 자정을 위한 타이머를 다시 설정
    Timer(timeUntilMidnight, () {
      _countdownAdsRemove();
      _setNextMidnightTimer(); // 다음날 자정을 위한 타이머 재설정
    });
  }

  // 매일 자정에 광고 제거 일수를 1일씩 감소시키는 함수
  void _countdownAdsRemove() {
    if (_adsRemoveDaysLeft > 0) {
      _adsRemoveDaysLeft -= 1;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('adsRemoveDaysLeft', _adsRemoveDaysLeft); // 감소된 일수를 저장
      });
      notifyListeners(); // UI에 상태가 변경되었음을 알림
    }
  }

  // 포인트를 1분마다 추가하는 타이머를 시작하는 함수
  void _startPointTimer() {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      if (_rewards < 100) {
        // 하루 최대 100P까지만 추가
        _rewards += 1;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('rewards', _rewards); // 추가된 포인트를 저장
        notifyListeners(); // UI에 상태가 변경되었음을 알림
      }
    });
  }

  // 광고 제거 기능을 활성화하고 포인트를 차감하는 함수
  void removeAds(BuildContext context) async {
    if (_rewards >= 2000) {
      // 2000P 이상일 때만 실행
      _rewards -= 2000; // 포인트 차감
      _adsRemoveDaysLeft = 30; // 광고 제거 30일 설정
      _adsRemoved = true; // 광고 제거 활성화
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('rewards', _rewards); // 업데이트된 포인트를 저장
      await prefs.setInt(
          'adsRemoveDaysLeft', _adsRemoveDaysLeft); // 광고 제거 일수를 저장
      await prefs.setBool('adsRemoved', _adsRemoved); // 광고 제거 상태를 저장
      notifyListeners(); // UI에 상태가 변경되었음을 알림

      // 광고 제거 완료 모달 표시
      _showAdsRemovedDialog(context);
    }
  }

  // 광고 제거 완료 모달을 표시하는 함수
  void _showAdsRemovedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('광고 제거 완료'),
          content: Text('광고제거 30일 적용되었어요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 테스트를 위한 함수: 포인트와 광고 제거 일수를 설정하는 함수
//  void setTestValues(int rewards, int adsRemoveDaysLeft) async {
//    _rewards = rewards; // 테스트용 포인트 설정
//    _adsRemoveDaysLeft = adsRemoveDaysLeft; // 테스트용 광고 제거 일수 설정
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setInt('rewards', _rewards);
//    await prefs.setInt('adsRemoveDaysLeft', _adsRemoveDaysLeft);
//    notifyListeners(); // 상태 변경 알림
//  }
}
