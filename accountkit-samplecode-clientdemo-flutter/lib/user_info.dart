/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'dart:convert';
import './main.dart';
import 'login_ohos_view.dart';

String viewTypeId = 'com.example.flutter_login/userInfoView';

class UserInfo extends StatelessWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onUserInfoViewCreated(LoginViewController controller) {
      controller.customDataStream.listen((data) {
        final result = jsonDecode(data);
        switch (result['method']) {
          case 'logout':
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MyHome()),
                (Route<dynamic> roter) => false);
            break;

          default:
            break;
        }
      });
    }

    return Scaffold(
      body: LoginOhosView(onUserInfoViewCreated, viewTypeId),
    );
  }
}
