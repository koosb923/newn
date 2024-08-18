import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

class JSInjector {
  static Future<String?> loadJavaScript() async {
    final url = "https://newn.pages.dev/youtube.js";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("JavaScript 파일 로드 실패: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("JavaScript 파일 로드 중 오류 발생: $e");
      return null;
    }
  }

  static void injectJavaScript(
      InAppWebViewController controller, String? jsContent) async {
    if (jsContent != null && controller != null) {
      try {
        await controller.evaluateJavascript(source: jsContent);
        print("JavaScript가 성공적으로 주입되었습니다.");
      } catch (e) {
        print("JavaScript 주입 중 오류 발생: $e");
      }
    }
  }
}
