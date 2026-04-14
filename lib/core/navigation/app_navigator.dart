import 'dart:developer';

import 'package:video_toolkit/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class NavigatorKey {
  static final key = GlobalKey<NavigatorState>();
}

class NavController {
  static Future<T?>? pushNamed<T extends Object?>(
      AppRoutes route, {
        Map<String, dynamic>? arguments,
      }) => NavigatorKey.key.currentState?.pushNamed(route.path, arguments: route);

  static Future<T?>? pushReplacementNamed<T extends Object?>(
      AppRoutes route, {
        Map<String, dynamic>? arguments,
      }) =>
      NavigatorKey.key.currentState
          ?.pushReplacementNamed(route.path, arguments: route);

  static Future<T?>? popAndPushNamed<T extends Object?>(
      AppRoutes route, {
        Map<String, dynamic>? arguments,
      }) =>
      NavigatorKey.key.currentState
          ?.popAndPushNamed(route.path, arguments: route);

  static pushNamedAndRemoveUntil(String newRouteName,
      {String? heldRouteName, Map<String, dynamic>? arguments}) {
    NavigatorKey.key.currentState?.pushNamedAndRemoveUntil(
      newRouteName,
      heldRouteName != null
          ? ModalRoute.withName(heldRouteName)
          : (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  static void pop([dynamic result]) {
    NavigatorKey.key.currentState?.pop(result);
  }

  static void maybePop([dynamic result]) {
    NavigatorKey.key.currentState?.maybePop(result);
  }

  static void popUntil(String routeName, {dynamic result}) {
    popUntilUnIdentifiedRoute([routeName], result: result);
  }

  /// if passing data ([result] != null), type of [arguments] must be defined as
  /// Map`<`String, dynamic`>` in [settings] of [onGenerateRoute]
  static void popUntilUnIdentifiedRoute(List<String> routeNames,
      {dynamic result}) {
    try {
      NavigatorKey.key.currentState?.popUntil((route) {
        log('NavController|popUtilUnIdentifiedRoute: route = ${route.settings.name}');
        bool isPopped = false;
        for (var routeName in routeNames) {
          log('NavController|popUtilUnIdentifiedRoute: routeName = $routeName');
          if (route.settings.name == routeName) {
            if (result != null) {
              (route.settings.arguments as Map)['result'] = result;
            }
            isPopped = true;
            break;
          } else {
            log('NavController|popUtilUnIdentifiedRoute: false');
            isPopped = false;
          }
        }
        return isPopped;
      });
    } catch (e) {
      log('NavController: error = $e');
    }
  }

  /// get result from [popUtilUnIdentifiedRoute]
  static dynamic getResultFromPopUtil(BuildContext context) {
    final arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return arguments['result'];
  }
}
