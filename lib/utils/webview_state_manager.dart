import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';

class WebViewStateManager {
  static Future<void> saveScrollPosition(
      InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        var scrollPosition = window.scrollY || window.pageYOffset;
        localStorage.setItem('scrollPosition', scrollPosition);
      """);
    } catch (e) {
      print('스크롤 위치 저장 중 오류 발생: $e');
    }
  }

  static Future<void> restoreScrollPosition(
      InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        var scrollPosition = localStorage.getItem('scrollPosition') || 0;
        window.scrollTo(0, scrollPosition);
      """);
    } catch (e) {
      print('스크롤 위치 복원 중 오류 발생: $e');
    }
  }

  static Future<void> saveInputValues(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        var inputs = document.querySelectorAll('input, textarea');
        inputs.forEach(function(input) {
          localStorage.setItem(input.name || input.id, input.value);
        });
      """);
    } catch (e) {
      print('입력 값 저장 중 오류 발생: $e');
    }
  }

  static Future<void> restoreInputValues(
      InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        var inputs = document.querySelectorAll('input, textarea');
        inputs.forEach(function(input) {
          var storedValue = localStorage.getItem(input.name || input.id);
          if (storedValue) {
            input.value = storedValue;
          }
        });
      """);
    } catch (e) {
      print('입력 값 복원 중 오류 발생: $e');
    }
  }

  static Future<void> saveVideoState(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        var videos = document.querySelectorAll('video');
        videos.forEach(function(video, index) {
          var state = {
            currentTime: video.currentTime,
            paused: video.paused
          };
          sessionStorage.setItem('videoState_' + index, JSON.stringify(state));
        });
      """);
    } catch (e) {
      print('비디오 상태 저장 중 오류 발생: $e');
    }
  }

  static Future<void> restoreVideoState(
      InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        var videos = document.querySelectorAll('video');
        videos.forEach(function(video, index) {
          var state = JSON.parse(sessionStorage.getItem('videoState_' + index));
          if (state) {
            video.currentTime = state.currentTime;
            if (!state.paused) {
              video.play();
            }
          }
        });
      """);
    } catch (e) {
      print('비디오 상태 복원 중 오류 발생: $e');
    }
  }

  static Future<void> pauseVideo(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        var videos = document.querySelectorAll('video');
        videos.forEach(function(video) {
          video.pause();
        });
      """);
    } catch (e) {
      print('비디오 일시 중지 중 오류 발생: $e');
    }
  }

  static Future<InAppWebViewController?> createWebViewForUrl(String url,
      Map<String, InAppWebViewController> webViewControllers) async {
    try {
      InAppWebViewController? controller;

      InAppWebView webView = InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
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
        onWebViewCreated: (InAppWebViewController webViewController) {
          controller = webViewController;
          webViewControllers[url] = webViewController;
          print("웹뷰 생성 및 컨트롤러 저장: $url");
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
        onConsoleMessage: (controller, consoleMessage) {
          print("웹뷰 콘솔 메시지: ${consoleMessage.message}");
        },
      );

      // 여기에서 실제로 위젯을 렌더링하고, controller가 생성되었는지 확인
      runApp(MaterialApp(
        home: Scaffold(
          body: Container(child: webView),
        ),
      ));

      await Future.delayed(Duration(milliseconds: 100));

      if (controller == null) {
        throw Exception("웹뷰 컨트롤러가 null입니다.");
      }

      return controller;
    } catch (e) {
      print("웹뷰 생성 중 오류 발생: $e");
      return null;
    }
  }
}
