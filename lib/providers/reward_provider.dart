import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardProvider with ChangeNotifier {
  int _rewards = 0;
  bool _adsRemoved = false;

  int get rewards => _rewards;
  bool get adsRemoved => _adsRemoved;

  RewardProvider() {
    _loadRewards();
  }

  void _loadRewards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rewards = prefs.getInt('rewards') ?? 0;
    _adsRemoved = prefs.getBool('adsRemoved') ?? false;
    notifyListeners();
  }

  void addReward() async {
    _rewards += 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rewards', _rewards);
    notifyListeners();
  }

  void removeAds() async {
    if (_rewards >= 100) {
      // 예: 100 리워드로 광고 제거 가능
      _rewards -= 100;
      _adsRemoved = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('rewards', _rewards);
      await prefs.setBool('adsRemoved', _adsRemoved);
      notifyListeners();
    }
  }
}
