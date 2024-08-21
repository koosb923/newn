import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../services/webview_manager.dart';
import '../utils/site_config.dart';
import 'floating_button.dart';
import 'bottom_sheet.dart';

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewManager? webViewManager;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setStatusBarStyle();
  }

  void _setStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      await loadSiteConfigs();
      print("사이트 설정이 로드되었습니다: ${siteConfigs.length}");

      if (siteConfigs.isNotEmpty) {
        setState(() {
          webViewManager = WebViewManager(
            siteConfigs: siteConfigs,
            currentWebView: siteConfigs[0].url.startsWith('http')
                ? siteConfigs[0].url
                : 'https://${siteConfigs[0].url}',
          );
          isLoading = false;
        });
      } else {
        throw Exception('사이트 설정을 찾을 수 없습니다.');
      }
    } catch (error) {
      print('사이트 설정 로드 실패: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: webViewManager!.backgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(
              index: webViewManager!.getCurrentIndex(),
              children: webViewManager!.buildWebViews(),
            ),
            Positioned(
              bottom: 150.0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingButton(
                  onPressed: () => showCustomBottomSheet(
                    context,
                    (url) {
                      setState(() {
                        isLoading = true;
                        webViewManager!.switchWebView(url);
                        isLoading = false;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
}
