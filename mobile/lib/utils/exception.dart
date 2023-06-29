import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class NetworkConnectionException implements Exception {
  String cause;
  NetworkConnectionException(this.cause);
}

Future<void> logException(
  exception,
  StackTrace? stackTrace,
) async {
  final unHandledExceptions = [
    SocketException,
    TimeoutException,
  ];

  debugPrint('$exception\n$stackTrace');
  if (!kReleaseMode || unHandledExceptions.contains(exception.runtimeType)) {
    return;
  }

  try {
    FirebaseCrashlytics.instance
        .recordError(exception, stackTrace, fatal: true);
  } catch (e) {
    debugPrint(e.toString());
  }
}
