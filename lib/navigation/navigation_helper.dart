import 'package:flutter/material.dart';
import 'package:spogpaws/navigation/page_transition.dart';

class NavigatorHelper {
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    PageTransitionType transition = PageTransitionType.cupertino,
  }) {
    return Navigator.of(
      context,
    ).push(AppPageTransition.build(page, type: transition));
  }

  static Future<T?> replace<T>(
    BuildContext context,
    Widget page, {
    PageTransitionType transition = PageTransitionType.cupertino,
  }) {
    return Navigator.of(
      context,
    ).pushReplacement(AppPageTransition.build(page, type: transition));
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  static void popUntilRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
