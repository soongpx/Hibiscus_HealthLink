import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'health_data.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'health_insights_page.dart';
import 'notification_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // For FlutterFire CLI users
  );
  // FirebaseDatabase.instance.setPersistenceEnabled(true);
  runApp(
    ChangeNotifierProvider(
      create: (context) => HealthData(), // Provide HealthData instance
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hibiscus HealthLink',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HealthDashboard(),
    );
  }
}

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  _HealthDashboardState createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  int _currentIndex = 0;

  // List of pages for BottomNavigationBar
  final List<Widget> _pages = [
    HomePage(), // Home Page
    const HealthInsightsPage(), // Insights Page
    const NotificationsPage(), // Notifications Page
    const ProfilePage(), // Profile Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Hibiscus ',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              TextSpan(
                text: 'Health',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              TextSpan(
                text: 'Link',
                style: TextStyle(
                  color: const Color(0xFF30C1AE),
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          CircleAvatar(
            backgroundImage: const AssetImage('assets/user_avatar.jpg'),
            radius: 20.r,
          ),
          SizedBox(width: 10.w),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: _pages[_currentIndex], // Dynamically switch between pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update current index for navigation
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF30C1AE), // Green for selected item
        unselectedItemColor: Colors.black,
        showSelectedLabels: true, // Show labels for selected items
        showUnselectedLabels: true, // Show labels for unselected items
      ),
    );
  }
}
