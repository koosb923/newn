import 'package:http/http.dart' as http;

class ScriptUtils {
  static Future<String?> loadScript(String url) async {
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
}
