import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'services/exam_service.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExamService()),
      ],
      child: const AmadeyaApp(),
    ),
  );
}

class AmadeyaApp extends StatelessWidget {
  const AmadeyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ئامادەیا - پۆلی ١٢',
      debugShowCheckedModeBanner: false,

      // Kurdish / Arabic Right-to-Left (RTL) Localization
      locale: const Locale('ku', 'IQ'),
      supportedLocales: const [
        Locale('ku', 'IQ'),
        Locale('ar', 'IQ'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Dark Theme with Kurdish Typography
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.indigo,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.indigo,
          secondary: AppColors.amber,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        textTheme: GoogleFonts.vazirmatnTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),

      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
