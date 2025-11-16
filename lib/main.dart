import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/list_users_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buddy Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA1EDA4)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('AUTHWRAPPER: Building AuthWrapper');
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('AUTHWRAPPER: StreamBuilder rebuild - connectionState: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, user: ${snapshot.data?.email}');

        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('AUTHWRAPPER: Showing loading spinner (waiting for auth state)');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('AUTHWRAPPER: User is logged in, showing MainTabNavigator for ${snapshot.data!.email}');
          return const MainTabNavigator();
        }

        // User is not logged in
        debugPrint('AUTHWRAPPER: No user logged in, showing AuthScreen');
        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showSignUp = true;

  void _toggleView() {
    debugPrint('AUTHSCREEN: Toggling view from ${_showSignUp ? "SignUp" : "Login"} to ${_showSignUp ? "Login" : "SignUp"}');
    setState(() {
      _showSignUp = !_showSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AUTHSCREEN: Building ${_showSignUp ? "SignUpScreen" : "LoginScreen"}');
    return _showSignUp
        ? SignUpScreen(onToggle: _toggleView)
        : LoginScreen(onToggle: _toggleView);
  }
}

class MainTabNavigator extends StatefulWidget {
  const MainTabNavigator({super.key});

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ListUsersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFA1EDA4),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Buddies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
