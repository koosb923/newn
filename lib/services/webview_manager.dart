import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/site_config.dart';
import '../utils/webview_state_manager.dart';
import '../utils/webview_switcher.dart';

class WebViewManager extends ChangeNotifier {
  final List<SiteConfig> siteConfigs;
  final Map<String, InAppWebViewController> webViewControllers = {};
  String currentWebView;
  Color _backgroundColor = Colors.black;
  Color _shadowColor = Colors.black.withOpacity(0.5);

  late final WebViewSwitcher _webViewSwitcher;

  WebViewManager({
    required this.siteConfigs,
    required this.currentWebView,
  }) {
    if (siteConfigs.isNotEmpty) {
      currentWebView = siteConfigs[0].url.startsWith('http')
          ? siteConfigs[0].url
          : 'https://${siteConfigs[0].url}';
      applySiteConfig(currentWebView);
    }

    _webViewSwitcher = WebViewSwitcher(
      webViewControllers: webViewControllers,
      applySiteConfig: applySiteConfig,
      currentWebView: currentWebView,
      notifyUIUpdate: _notifyUIUpdate,
    );
  }

  int getCurrentIndex() {
    int index =
        siteConfigs.indexWhere((config) => currentWebView == config.url);
    print("현재 웹뷰 인덱스: $index, URL: $currentWebView");
    return index == -1 ? 0 : index;
  }

  Color get backgroundColor => _backgroundColor;
  Color get shadowColor => _shadowColor;

  void applySiteConfig(String urlPattern) {
    SiteConfig config = siteConfigs.firstWhere(
      (config) => urlPattern.contains(config.url),
      orElse: () => SiteConfig(
        url: 'default',
        buttonText: '기본',
        scriptUrl: '',
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.5),
        injectScript: false,
        iconUrl: '',
      ),
    );

    _backgroundColor = config.backgroundColor;
    _shadowColor = config.shadowColor;
    print("사이트 설정 적용 완료: $urlPattern");
  }

  Future<void> switchWebView(String urlPattern) async {
    if (currentWebView == urlPattern) {
      print("이미 동일한 웹뷰가 활성화되어 있습니다: $urlPattern");
      return;
    }

    try {
      await _webViewSwitcher.switchWebView(urlPattern);
      _notifyUIUpdate(); // 웹뷰 전환 후 UI 강제 업데이트
    } catch (e) {
      print("웹뷰 전환 중 오류 발생: $e");
    }
  }

  void _notifyUIUpdate() {
    notifyListeners(); // UI 업데이트를 위한 ChangeNotifier 사용
  }

  Widget buildCurrentWebView() {
    String formattedUrl = currentWebView.startsWith('http')
        ? currentWebView
        : 'https://$currentWebView';

    if (!webViewControllers.containsKey(formattedUrl)) {
      return Center(child: CircularProgressIndicator());
    }

    InAppWebViewController? controller = webViewControllers[formattedUrl];
    if (controller == null) {
      return Center(child: Text("WebView 로드 실패"));
    }

    return Offstage(
      offstage: false,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              spreadRadius: 6,
              blurRadius: 128,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(formattedUrl),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                clearCache: false,
                disableContextMenu: true,
              ),
              android: AndroidInAppWebViewOptions(
                allowFileAccess: false,
                useWideViewPort: true,
                supportMultipleWindows: false,
                cacheMode: AndroidCacheMode.LOAD_DEFAULT,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewControllers[formattedUrl] = controller;
              print("웹뷰 컨트롤러 생성 성공: $formattedUrl");
            },
            onLoadStart: (controller, url) {
              print("웹뷰 로딩 시작: $url");
            },
            onLoadStop: (controller, url) {
              print("웹뷰 로딩 완료: $url");
            },
            onLoadError: (controller, url, code, message) {
              print("웹뷰 로딩 실패: $url, 에러: $message");
            },
          ),
        ),
      ),
    );
  }
}
