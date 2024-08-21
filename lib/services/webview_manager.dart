import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/site_config.dart';

class WebViewManager {
  final List<SiteConfig> siteConfigs;
  Map<String, InAppWebViewController> webViewControllers = {};
  String currentWebView;
  Color _backgroundColor = Colors.black;
  Color _shadowColor = Colors.black.withOpacity(0.5);

  WebViewManager({required this.siteConfigs, required this.currentWebView}) {
    if (siteConfigs.isNotEmpty) {
      // 첫 번째 사이트로 초기화
      currentWebView = siteConfigs[0].url.startsWith('http')
          ? siteConfigs[0].url
          : 'https://${siteConfigs[0].url}';
      applySiteConfig(currentWebView);
    }
  }

  int getCurrentIndex() {
    return siteConfigs.indexWhere((config) => config.url == currentWebView);
  }

  Color get backgroundColor => _backgroundColor;
  Color get shadowColor => _shadowColor;

  void applySiteConfig(String urlPattern) {
    // 기본 설정을 별도로 정의하여 코드 중복을 피함
    SiteConfig defaultConfig = SiteConfig(
      url: 'default',
      buttonText: 'Default',
      scriptUrl: '',
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.5),
      injectScript: false,
      iconUrl: '',
    );

    SiteConfig config = siteConfigs.firstWhere(
      (config) => urlPattern.contains(config.url),
      orElse: () => defaultConfig,
    );

    _backgroundColor = config.backgroundColor;
    _shadowColor = config.shadowColor;
  }

  void switchWebView(String urlPattern) async {
    currentWebView = urlPattern;
    applySiteConfig(urlPattern);

    // URL이 http로 시작하지 않으면 https를 추가
    String formattedUrl =
        urlPattern.startsWith('http') ? urlPattern : 'https://$urlPattern';

    if (webViewControllers.containsKey(formattedUrl)) {
      InAppWebViewController controller = webViewControllers[formattedUrl]!;

      // 해당 URL의 웹뷰를 로드
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(formattedUrl)),
      );
    } else {
      print("해당 URL 패턴에 대한 WebView를 찾을 수 없습니다: $formattedUrl");
    }
  }

  List<Widget> buildWebViews() {
    return siteConfigs.map((config) {
      String formattedUrl =
          config.url.startsWith('http') ? config.url : 'https://${config.url}';

      print("WebView를 생성 중입니다. URL: $formattedUrl");

      return Offstage(
        offstage: currentWebView != formattedUrl,
        child: Container(
          decoration: BoxDecoration(
            color: config.backgroundColor, // JSON에서 가져온 배경색 적용
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            boxShadow: [
              BoxShadow(
                color: config.shadowColor, // JSON에서 가져온 그림자 색상 적용
                spreadRadius: 1,
                blurRadius: 80,
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
                  useOnLoadResource: false,
                  clearCache: false,
                  disableContextMenu: true,
                  userAgent:
                      "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15A372 Safari/604.1",
                ),
                android: AndroidInAppWebViewOptions(
                  allowFileAccess: false,
                  useWideViewPort: true,
                  supportMultipleWindows: false,
                  cacheMode: AndroidCacheMode.LOAD_DEFAULT,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                  allowsAirPlayForMediaPlayback: false,
                  allowsPictureInPictureMediaPlayback: false,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                webViewControllers[formattedUrl] = controller;
                print("WebView가 생성되었습니다. URL: $formattedUrl");
              },
              onLoadStart: (controller, url) {
                print("WebView 로딩 시작: $url");
              },
              onLoadStop: (controller, url) {
                print("WebView 로딩 완료: $url");
              },
              onLoadError: (controller, url, code, message) {
                print("WebView 로딩 실패: $url, 에러: $message");
              },
            ),
          ),
        ),
      );
    }).toList();
  }
}
