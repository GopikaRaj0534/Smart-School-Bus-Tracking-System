import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'utils/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/bus_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
      ],
      child: const InactivityWatcher(
        child: RouteSafeApp(),
      ),
    );
  }
}

class RouteSafeApp extends StatelessWidget {
  const RouteSafeApp({super.key});

  // Global navigator key to allow redirection from anywhere, even without context
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RouteSafe',
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// A wrapper widget that listens to all user interactions (touch gestures)
/// and resets an inactivity timer. If no interaction happens for 5 minutes,
/// the user is automatically logged out and redirected to the login screen.
class InactivityWatcher extends StatefulWidget {
  final Widget child;

  const InactivityWatcher({Key? key, required this.child}) : super(key: key);

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  Timer? _inactivityTimer;
  
  // Timeout duration: 5 minutes (300 seconds)
  static const int timeoutSeconds = 300;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    // Cancel existing timer
    _inactivityTimer?.cancel();

    // Start a new timer
    _inactivityTimer = Timer(const Duration(seconds: timeoutSeconds), _handleTimeout);
  }

  Future<void> _handleTimeout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Only logout if a user session is active
    if (authProvider.currentUser != null) {
      await authProvider.logout();
      
      final navState = RouteSafeApp.navigatorKey.currentState;
      if (navState != null) {
        // Redirect to Login Screen and clear route history
        navState.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );

        // Display a warning message
        ScaffoldMessenger.of(navState.context).showSnackBar(
          const SnackBar(
            content: Text('Session expired due to 5 minutes of inactivity. Please login again.'),
            backgroundColor: AppTheme.errorColor,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        // Any touch interaction resets the timer
        _resetTimer();
        // Also record timestamp in SharedPreferences for verification
        Provider.of<AuthProvider>(context, listen: false).recordActivity();
      },
      onPointerMove: (_) {
        _resetTimer();
        Provider.of<AuthProvider>(context, listen: false).recordActivity();
      },
      child: widget.child,
    );
  }
}
