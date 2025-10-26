/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnViewCreated = Function(LoginViewController);

// Define the one-tap sign-in component.
class LoginOhosView extends StatefulWidget {
  final OnViewCreated onViewCreated;
  final String viewTypeId;

  const LoginOhosView(this.onViewCreated, this.viewTypeId, {Key? key})
      : super(key: key);

  @override
  State<LoginOhosView> createState() => _LoginOhosViewState();
}

class _LoginOhosViewState extends State<LoginOhosView> {
  late MethodChannel _channel;

  @override
  Widget build(BuildContext context) {
    return OhosView(
      // The value of viewType must be the same as that of viewTypeId specified when you implement registerViewFactory in FlutterPlugin on the Native side.
      viewType: widget.viewTypeId,
      onPlatformViewCreated: (int id) {
        _channel = MethodChannel('${widget.viewTypeId}$id');
        final controller = LoginViewController._(
          _channel,
        );
        widget.onViewCreated(controller);
      },
      creationParams: const <String, dynamic>{},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

// Implement interaction between the Dart and Native sides.
class LoginViewController {
  final MethodChannel _channel;
  final StreamController<String> _controller = StreamController<String>();

  LoginViewController._(
    this._channel,
  ) {
    _channel.setMethodCallHandler(
      (call) async {
        // Obtain data from the Native side.
        final result = call.arguments as String;
        final data = {
          'method': call.method,
          'data': result,
        };
        _controller.sink.add(jsonEncode(data));
      },
    );
  }

  Stream<String> get customDataStream => _controller.stream;

  // Send data to the Native side.
  Future<void> sendMessageToOhosView(String method, message) async {
    print('sendMessageToOhosView: $method ${message.toString()}');
    await _channel.invokeMethod(
      method,
      message,
    );
  }
}
