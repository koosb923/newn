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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      await loadSiteConfigs();
      if (siteConfigs.isNotEmpty) {
        webViewManager = WebViewManager(
          siteConfigs: siteConfigs,
          currentWebView: siteConfigs[0].url.startsWith('http')
              ? siteConfigs[0].url
              : 'https://${siteConfigs[0].url}',
        );
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print('사이트 설정 불러오기 실패: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || webViewManager == null) {
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
            webViewManager!.buildCurrentWebView(),
            Positioned(
              bottom: 150.0,
              left: 0,
              child: FloatingButton(
                onPressed: () => showCustomBottomSheet(
                  context,
                  (url) async {
                    if (!mounted) return;
                    setState(() => isLoading = true);
                    await webViewManager!.switchWebView(url);
                    if (!mounted) return;
                    setState(() => isLoading = false);
                    print('WebView로 전환: $url');
                  },
                ),
              ),
            ),
            if (isLoading)
              Center(child: CircularProgressIndicator()), // 로딩 상태 표시
          ],
        ),
      ),
    );
  }
}
