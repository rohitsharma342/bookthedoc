import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'utils/theme.dart';
import 'services/data_service.dart';
import 'services/supabase_service.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://slobnvonxnibzindripw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsb2Judm9ueG5pYnppbmRyaXB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczMjg1NTksImV4cCI6MjA4MjkwNDU1OX0.Td4XcnVs4r66EXKAuedSPqzIZU0qyeF5VUVnBM3O3zU',
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => DataService()),
      ],
      child: MaterialApp(
        title: 'BookTheDoc',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }
}