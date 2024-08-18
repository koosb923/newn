import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
        statusBarColor: Colors.transparent, // 상태바 배경색 투명
        statusBarIconBrightness: Brightness.light, // 상태바 아이콘과 텍스트를 흰색으로 설정
        statusBarBrightness: Brightness.dark, // iOS에서 상태바의 밝기 조정
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      await loadSiteConfigs();
      print("Site configs loaded: ${siteConfigs.length}");

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
        throw Exception('No site configurations found.');
      }
    } catch (error) {
      print('Failed to load site configs: $error');
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
}
