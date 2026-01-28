import 'package:accountanter/features/auth/activation_screen.dart';
import 'package:accountanter/features/auth/auth_service.dart';
import 'package:accountanter/features/auth/login_screen.dart';
import 'package:accountanter/features/main/main_screen.dart';
import 'package:accountanter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import this
import 'l10n/app_localizations.dart';

enum AppStatus { uninitialized, unactivated, loggedOut, loggedIn }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppStatus _status = AppStatus.uninitialized;
  late final AuthService _authService;
  String? _prefilledUsername;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _initializeApp();
    _loadLocaleSetting();
  }
  
  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final isActivated = await _authService.isAppActivated();
    if (!isActivated) {
      setState(() => _status = AppStatus.unactivated);
      return;
    }

    final rememberedUser = await _authService.getLoggedInUser();
    if (rememberedUser != null) {
      setState(() => _status = AppStatus.loggedIn);
    } else {
      final user = await _authService.database.getLocalUser();
      setState(() {
        _prefilledUsername = user?.username;
        _status = AppStatus.loggedOut;
      });
    }
  }

  Future<void> _loadLocaleSetting() async {
    final code = await _authService.database.getSettingString('ui.locale');
    if (!mounted) return;
    if (code == null || code.trim().isEmpty) return;
    setState(() => _locale = Locale(code.trim()));
  }

  void _onLocaleChanged(Locale locale) {
    setState(() => _locale = locale);
  }

  void _onActivatedOrLoggedIn() {
    setState(() => _status = AppStatus.loggedIn);
  }
  
  void _onLogout() async {
    await _authService.logout();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accountanter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _locale,
      
      // Add Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      
      home: _buildHomeScreen(),
    );
  }

  Widget _buildHomeScreen() {
    switch (_status) {
      case AppStatus.uninitialized:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AppStatus.unactivated:
        return ActivationScreen(onActivated: _initializeApp);
      case AppStatus.loggedOut:
        return LoginScreen(onLogin: _onActivatedOrLoggedIn, prefilledUsername: _prefilledUsername);
      case AppStatus.loggedIn:
        return MainScreen(onLogout: _onLogout, onLocaleChanged: _onLocaleChanged);
    }
  }
}
