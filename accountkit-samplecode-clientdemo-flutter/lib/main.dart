/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/login_ohos_view.dart';
import 'login_page.dart';

String viewTypeId = 'com.example.flutter_login/mainView';

void main(List<String> args) {
  runApp(const MaterialApp(home: MyHome()));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MaterialApp(home: MyHome()));
  });
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    void onMainViewCreated(LoginViewController controller) {
      controller.customDataStream.listen((data) {
        // Receive data from the Native side.
        final result = jsonDecode(data);
        switch (result['method']) {
          case 'jumpToLoginPage':
            // Redirect to the sign-in screen.
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()));
            break;

          default:
            break;
        }
      });
    }

    return Scaffold(
      body: LoginOhosView(onMainViewCreated, viewTypeId),
    );
  }
}
