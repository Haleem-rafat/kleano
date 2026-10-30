import 'package:flutter/material.dart';

void pushPage(BuildContext context, Widget widget) {
  if (context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => widget),
    );
  }
}

void pushReplacement(BuildContext context, Widget widget) {
  if (context.mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => widget),
    );
  }
}

void popALlAndPushPage(BuildContext context, Widget widget) {
  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => widget),
      (Route route) => false,
    );
  }
}

void popAllAndPushName(BuildContext context, String widget) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    widget,
    (Route route) => false,
  );
}

Future<dynamic> pushName(BuildContext context, String route,
    {dynamic arguments}) async {
  return await Navigator.of(context).pushNamed(route, arguments: arguments);
}

Future<dynamic> pushNameForResult(BuildContext context, String route) async {
  return await Navigator.of(context).pushNamed(route);
}

Future<dynamic> pushNameWithArgumentsForResult(
    BuildContext context, String route, dynamic argument) async {
  return await Navigator.of(context).pushNamed(route, arguments: argument);
}

void pushNameWithArguments(
    BuildContext context, String route, dynamic argument) {
  Navigator.of(context).pushNamed(route, arguments: argument);
}

pushPageForResult(BuildContext context, Widget widget) async {
  return await Navigator.of(context).push(
    MaterialPageRoute(builder: (BuildContext context) => widget),
  );
}

void popScreen(BuildContext context, int size) {
  int count = 0;
  Navigator.of(context).popUntil((_) => count++ >= size);
}

void pop(BuildContext context, [dynamic result]) {
  Navigator.pop(context, result);
}

void popAndPushName(BuildContext context, String route, {dynamic arguments}) {
  Navigator.of(context).popAndPushNamed(route, arguments: arguments);
}

pushWidgetWithFade(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    PageRouteBuilder(
        transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation, Widget child) =>
            FadeTransition(opacity: animation, child: child),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return widget;
        }),
  );
}

Future<bool> onWillPop(BuildContext context, Widget widget) {
  pushPage(context, widget);
  return Future.value(true);
}

Future<bool> onWillPopPage(BuildContext context) {
  pop(context);
  return Future.value(true);
}

Route createRoute(Widget widget) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        widget,
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      const Offset begin = Offset(1.0, 0.0);
      const Offset end = Offset.zero;
      const Cubic curve = Curves.ease;

      Animatable<Offset> tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
