import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/webview_screen.dart';
import 'providers/reward_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RewardProvider(),
      child: const MyApp(), // const 추가
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // const 추가

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'newn - 눈',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewScreen(),
    );
  }
}
