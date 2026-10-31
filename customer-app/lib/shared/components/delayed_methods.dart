  
  import 'package:flutter/material.dart';

void delayedExecution(BuildContext context, Duration duration, Function function) {
    Future<void>.delayed(duration, () => function());
  }