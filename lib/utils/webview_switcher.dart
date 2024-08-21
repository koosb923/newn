import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'webview_state_manager.dart';
import '../utils/site_config.dart';
import 'package:flutter/foundation.dart';

class WebViewSwitcher {
  final Map<String, InAppWebViewController> webViewControllers;
  final Function(String) applySiteConfig;
  final VoidCallback _notifyUIUpdate;
  String currentWebView;

  WebViewSwitcher({
    required this.webViewControllers,
    required this.applySiteConfig,
    required this.currentWebView,
    required notifyUIUpdate,
  }) : _notifyUIUpdate = notifyUIUpdate;

  Future<void> switchWebView(String urlPattern) async {
    try {
      String formattedUrl =
          urlPattern.startsWith('http') ? urlPattern : 'https://$urlPattern';

      if (currentWebView == formattedUrl) {
        print("이미 동일한 웹뷰가 활성화되어 있습니다: $formattedUrl");
        return;
      }

      print("Switching to: $formattedUrl");
      if (webViewControllers.containsKey(currentWebView)) {
        InAppWebViewController? currentController =
            webViewControllers[currentWebView];
        if (currentController != null) {
          try {
            await WebViewStateManager.pauseVideo(currentController);
          } catch (e) {
            print("현재 웹뷰 컨트롤러가 유효하지 않음: $currentWebView");
            webViewControllers.remove(currentWebView);
          }
        }
      }

      currentWebView = formattedUrl;
      applySiteConfig(formattedUrl);

      if (webViewControllers.containsKey(formattedUrl)) {
        InAppWebViewController controller = webViewControllers[formattedUrl]!;
        await controller.loadUrl(
            urlRequest: URLRequest(url: WebUri(formattedUrl)));
        print("웹뷰 전환 완료: $formattedUrl");
      } else {
        print("새 웹뷰 생성 및 로드: $formattedUrl");
        InAppWebViewController? newController =
            await WebViewStateManager.createWebViewForUrl(
                formattedUrl, webViewControllers);
        if (newController == null) {
          print("새 웹뷰 생성 실패: $formattedUrl");
        }
      }

      print("WebView로 전환: $formattedUrl");

      _notifyUIUpdate();

      print(
          "현재 웹뷰 인덱스: ${webViewControllers.keys.toList().indexOf(currentWebView)}, URL: $currentWebView");
    } catch (e) {
      print("웹뷰 전환 중 오류 발생: $e");
    }
  }
}
