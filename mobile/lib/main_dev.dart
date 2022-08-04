import 'dart:io';

import 'package:app/app_config.dart';
import 'package:app/main_common.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/services/hive_service.dart';
import 'package:app/services/native_api.dart';
import 'package:app/services/notification_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'firebase_options_dev.dart';
import 'constants/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  HttpOverrides.global = AppHttpOverrides();
  await dotenv.load(fileName: Config.environmentFile);
  await HiveService.initialize();
  await SystemProperties.setDefault();

  await NotificationService.listenToNotifications();

  await initializeBackgroundServices();

  var configuredApp = AppConfig(
    appTitle: 'AirQo Dev',
    environment: Environment.dev,
    child: AirQoApp(),
  );

  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = Config.sentryDsn
          ..enableOutOfMemoryTracking = true
          ..tracesSampleRate = 1.0;
      },
      appRunner: () => runApp(configuredApp),
    );
  } else {
    runApp(configuredApp);
  }

  // mainCommon();
  // runApp(configuredApp);
}
