import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/shared_prefs_service.dart';
import 'app/data/services/hive_service.dart';
import 'app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.init();
  
  // Initialize SharedPreferences
  await SharedPrefsService.init();
  
  // Inisialisasi Supabase agar SupabaseService bisa langsung memakai
  // Supabase.instance.client untuk autentikasi dan CRUD nota.
  await Supabase.initialize(
    url: 'https://ssvadbzpckuyxxxlrjww.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNzdmFkYnpwY2t1eXh4eGxyand3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjY0MTQsImV4cCI6MjA3ODcwMjQxNH0.vnNVT6eK72tiEfopeD53eQG3S1_dMcSkdolx3k91VvQ', // Ganti dengan Anon Key Anda
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = SharedPrefsService.isDarkMode;
    
    return GetMaterialApp(
      title: 'Obral Laundry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}