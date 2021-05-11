import 'package:app/config/providers/LocalProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/languages/CustomLocalizations.dart';
import 'config/languages/l10n.dart';
import 'config/themes/light_theme.dart';
import 'constants/app_constants.dart';
import 'screens/home_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: appColor,
    statusBarColor: Colors.transparent,
    // statusBarBrightness: Brightness.light,
    // statusBarIconBrightness:Brightness.light ,
    // systemNavigationBarDividerColor: appColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  WidgetsFlutterBinding.ensureInitialized();

  runApp(AirqoApp());
}

class AirqoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => localProvider(),
      builder: (context, child) {
        final provider = Provider.of<localProvider>(context);
        return MaterialApp(
          localizationsDelegates: [
            const CustomLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            // GlobalWidgetsLocalizations.delegate,
            // GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          locale: provider.locale,
          title: appName,
          theme: lightTheme(),
          home: HomePage(),
        );
      },
    );
  }
}
