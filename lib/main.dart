import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/ui/calendar_page.dart';
import 'package:fray/features/settings/bloc/settings_state.dart';
import 'package:fray/models/enum_to_string.dart';
import 'repositories/settings_repository.dart';
import 'features/settings/bloc/settings_event.dart';
import 'package:fray/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = await SettingsRepository.getInstance(null);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp(settingsRepository: settingsRepository));
}

class MyApp extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const MyApp({super.key, required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(settingsRepository: settingsRepository),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: state.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.supportedLocales,
            locale: Locale(enumToString(state.language)),
            home: const CalendarPage(
              settingsState: SettingsState(),
            ),
          );
        },
      ),
    );
  }
}
