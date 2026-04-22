import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const double _kDefaultLoadingIndicatorSize = 50;
const Color _kLoadingBackground = Color(0xA6000000);
const Color _kLoadingProgress = Color(0xA63AFF19);
const Color _kLoadingMask = Color(0x80000000);

class LoadingUtil {
  static bool _isLoading = false;

  static void setup() {
    EasyLoading.instance
      ..backgroundColor = _kLoadingBackground
      ..maskType = EasyLoadingMaskType.custom
      ..indicatorColor = _kLoadingProgress
      ..progressColor = _kLoadingProgress
      ..textColor = _kLoadingProgress
      ..dismissOnTap = false
      ..boxShadow = [] // keep this to make backgroundColor take effect
      ..userInteractions = false
      ..maskColor = _kLoadingMask
      ..loadingStyle = EasyLoadingStyle.custom;
  }

  static Future<void> show({String? status, int? timeOut}) async {
    _setTimeOut(timeOut: timeOut ?? 30);
    if (_isLoading) return;

    _isLoading = true;
    await EasyLoading.show(
      status: status,
      dismissOnTap: false,
      indicator: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _kDefaultLoadingIndicatorSize),
        child: SpinKitRing(
          size: _kDefaultLoadingIndicatorSize,
          color: _kLoadingProgress,
          lineWidth: 3,
        ),
      ), // Chặn thao tác người dùng
    );
  }

  static Future<void> dismiss() async {
    _isLoading = false;
    await EasyLoading.dismiss();
  }

  static Future<void> showSuccess(String text, {int duration = 500}) =>
      EasyLoading.showSuccess(text, duration: Duration(milliseconds: duration));

  static Future<void> showError(String text, {int duration = 500}) =>
      EasyLoading.showError(text, duration: Duration(milliseconds: duration));

  static Future<void> showInfo(String text, {int duration = 500}) =>
      EasyLoading.showInfo(text, duration: Duration(milliseconds: duration));

  static Timer? _debounce;

  static void _setTimeOut({required int timeOut}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(seconds: timeOut), () {
      dismiss();
    });
  }
}
