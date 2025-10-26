/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_login/user_info.dart';
import 'package:flutter_login/webview.dart';
import 'login_ohos_view.dart';

const protocolURL =
    'https://privacy.consumer.huawei.com/legal/id/authentication-terms.htm?code=CN&language=zh-CN';

String loginButtonID =
    'com.example.flutter_login/loginView';
String privacyComponentID =
    'com.example.flutter_login/privacyView';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginExample(),
    );
  }
}

class LoginExample extends StatefulWidget {
  const LoginExample({Key? key}) : super(key: key);

  @override
  State<LoginExample> createState() => _LoginExampleState();
}

class _LoginExampleState extends State<LoginExample> {
  String phoneNumber = '';
  bool agreement = false; // Indicate whether the user accepts the agreement.
  LoginViewController? _loginButtonViewController;
  bool loadingLogin = false; // Indicate whether the user is signing in.
  BuildContext? contextRef;

  void onLoginButtonOhosViewCreated(LoginViewController controller) {
    _loginButtonViewController = controller;
    controller.customDataStream.listen((data) {
      // Receive data from the OHOS side.
      final result = jsonDecode(data);
      setState(() {
        switch (result['method']) {
          case 'quickLoginAnonymousPhone':
            // Obtain the anonymous mobile number.
            phoneNumber = result['data'];
            break;

          case 'loginSuccess':
            // Sign-in successful.
            Navigator.of(contextRef!).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const UserInfo()),
                (Route<dynamic> roter) => false);
            break;

          case 'openPrivacy':
            // Redirect to the screen that contains the agreement.
            String type = result['data'];
            Navigator.of(contextRef!)
                .push(MaterialPageRoute(
                    builder: (context) =>
                        const PrivacyWebView(title: protocolURL)))
                .then((value) {
              controller.sendMessageToOhosView('reOpenDialog', '');
            });
            break;

          case 'loginStart':
            // Sign-in starts.
            loadingLogin = true;
            break;

          case 'loginEnd':
            // Sign-in is complete.
            loadingLogin = false;
            break;

         case 'AgreementStatusChanged':
            // Consent Agreement.
            agreement = result['data'] == '1' ? true : false;
            break;

          default:
            // Unprocessed messages.
            break;
        }
      });
    });
  }

  void onPrivacyViewCreated(LoginViewController controller) {
    controller.customDataStream.listen((data) {
      // Receive data from the Native side.
      final result = jsonDecode(data);
      switch (result['method']) {
        case 'openPrivacy':
          Navigator.of(contextRef!).push(MaterialPageRoute(
              builder: (context) => const PrivacyWebView(title: protocolURL)));
          break;
        default:
          break;
      }
    });
  }

  // Sign-in button.
  Widget _loginButton() {
    return Column(children: [
      _buildLoginOhosView(),
      _buildOtherLogin(),
    ]);
  }

  // One-tap sign-in button.
  Widget _buildLoginOhosView() {
    return Container(
      height: 40,
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 448,
      ),
      child: LoginOhosView(onLoginButtonOhosViewCreated, loginButtonID),
    );
  }

  // Button for other sign-in methods.
  Widget _buildOtherLogin() {
    return Opacity(
      opacity: loadingLogin ? 0.6 : 1,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        constraints: const BoxConstraints(
          maxWidth: 448,
        ),
        height: 40,
        width: double.infinity,
        child: TextButton(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(const Color(0Xe5000000)),
              // Background color.
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                // Set the background color of the button when it is tapped.
                if (states.contains(MaterialState.pressed) && !loadingLogin) {
                  return const Color.fromARGB(32, 0, 0, 0);
                }
                // By default, no background color is used.
                return const Color(0xffe7e8ea);
              }),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ))),
          onPressed: () {},
          child: const Text(
            "其他方式登录",
            style: TextStyle(
                color: Color(0Xe5000000),
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Widget _buildFlutterView() {
    final size = MediaQuery.of(context).size;
    const double pagePadding = 16;
    double checkBoxWidth = 24;
    double checkBoxMarginRight = 6;
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: checkBoxWidth,
            height: checkBoxWidth,
            padding: const EdgeInsets.all(2),
            margin: EdgeInsets.only(right: checkBoxMarginRight),
            child: Opacity(
              opacity: loadingLogin ? 0.6 : 1,
              child: Checkbox(
                shape: const CircleBorder(),
                side: MaterialStateBorderSide.resolveWith(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return const BorderSide(
                        width: 1, color: Color.fromARGB(255, 205, 14, 45));
                  }
                  return const BorderSide(width: 1, color: Color(0x66000000));
                }),
                value: agreement,
                activeColor: const Color.fromARGB(255, 205, 14, 45),
                onChanged: (value) {
                  if (loadingLogin) {
                    return;
                  }
                  _loginButtonViewController?.sendMessageToOhosView(
                      'AgreementStatusChanged', value);
                  setState(() {
                    agreement = value!;
                  });
                },
              ),
            ),
          ),
          Container(
            width: size.width -
                pagePadding * 2 -
                checkBoxWidth -
                checkBoxMarginRight,
            height: 30,
            constraints: const BoxConstraints(maxWidth: 36 * 12),
            child: LoginOhosView(onPrivacyViewCreated, privacyComponentID),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    contextRef = context;

    return Container(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 28),
        color: const Color(0xFFF1F3F5),
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  // Back button.
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!loadingLogin) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Opacity(
                          opacity: loadingLogin ? 0.6 : 1,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: const DecorationImage(
                                    image: AssetImage('images/back.png')),
                              )),
                        ),
                      )
                    ],
                  ),

                  // App icon.
                  const Expanded(
                    child: Center(
                      child: Image(
                        image: AssetImage('images/appmarket.png'),
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),

                  // Display the mobile number bound to the HUAWEI ID.
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: const Text(
                      '华为账号绑定号码',
                      style: TextStyle(
                          color: Color(0x66000000), fontSize: 12, height: 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: _loginButton(),
                  ),
                  Expanded(child: Container()),
                  _buildFlutterView()
                ],
              ),
            )
          ],
        ));
  }
}
