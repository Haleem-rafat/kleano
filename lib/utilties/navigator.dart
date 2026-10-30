import 'package:flutter/material.dart';
import 'package:thewasher/modules/Home/screens/explore_screen.dart';

void pushPage(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (BuildContext context) => widget),
  );
}

void popALlAndPushPage(BuildContext context, Widget widget) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (BuildContext context) => widget),
    (Route route) => false,
  );
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

Route createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const ExploreScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
