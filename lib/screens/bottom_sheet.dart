import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/site_config.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';

void showCustomBottomSheet(
    BuildContext context, Function(String) switchWebView) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 내 포인트 및 광고 제거 남은 기간 또는 버튼 표시
                  Consumer<RewardProvider>(
                    builder: (context, rewardProvider, child) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '내 포인트',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${rewardProvider.rewards} P',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          if (rewardProvider.adsRemoveDaysLeft > 0)
                            Text(
                              '광고 제거 ${rewardProvider.adsRemoveDaysLeft}일 남음',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ElevatedButton(
                              onPressed: rewardProvider.rewards >= 2000
                                  ? () {
                                      rewardProvider
                                          .removeAds(context); // Context 전달
                                      Navigator.pop(context);
                                    }
                                  : () {
                                      _showPointDialog(
                                          context, rewardProvider.rewards);
                                    },
                              child: Text('2,000P 사용하고 광고 제거'),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  // 사이트 리스트 표시
                  ...siteConfigs.map((config) {
                    return ListTile(
                      leading: Image.network(
                        config.iconUrl,
                        width: 24.0,
                        height: 24.0,
                      ),
                      title: Text(
                        config.buttonText,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansKR',
                        ),
                      ),
                      tileColor: Colors.white,
                      onTap: () {
                        print("Switching to: ${config.url}");
                        switchWebView(config.url);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                  SizedBox(height: 16.0),
                  // 테스트 버튼 추가
//                  ElevatedButton(
//                    onPressed: () {
//                      // 포인트를 2001로 설정하고 광고 제거 일수를 0으로 설정하는 테스트 코드
//                      Provider.of<RewardProvider>(context, listen: false)
//                          .setTestValues(2001, 0);
 //                     Navigator.pop(context); // 바텀시트를 닫고
//                      ScaffoldMessenger.of(context).showSnackBar(
//                        SnackBar(content: Text('테스트 값이 설정되었습니다.')),
//                      );
//                    },
//                    child: Text('테스트: 포인트 2001P, 광고 제거 0일로 설정'),
//                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showPointDialog(BuildContext context, int currentPoints) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('포인트가 부족합니다.'),
        content: Text(
            '2,000P 모아서 광고제거 30일 이용하세요.\n현재 포인트: $currentPoints P\n1분당 1P 하루 최대 100P까지 모을 수 있어요.'),
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
