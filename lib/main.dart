import 'package:flutter/material.dart';
import 'package:new_flutter_project/providers/admin_auth_provider.dart';
import 'package:new_flutter_project/providers/admin_banner_provider.dart';
import 'package:new_flutter_project/providers/admin_brand_provider.dart';
import 'package:new_flutter_project/providers/admin_offer_provider.dart';
import 'package:new_flutter_project/providers/admin_settings_provider.dart';
import 'package:new_flutter_project/providers/admin_stats_provider.dart';
import 'package:new_flutter_project/providers/admin_support_provider.dart';
import 'package:new_flutter_project/providers/admin_user_provider.dart';
import 'package:provider/provider.dart';

// Providers Import

import 'package:new_flutter_project/providers/admin_category_provider.dart';
import 'package:new_flutter_project/providers/admin_order_provider.dart';
import 'package:new_flutter_project/providers/admin_sub_category_provider.dart';
import 'package:new_flutter_project/providers/admin_product_provider.dart';

// Screens Import
import 'screens/admin_login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductProvider()),
        ChangeNotifierProvider(create: (_) => AdminCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminSubCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminSupportProvider()),
        ChangeNotifierProvider(create: (_) => AdminBannerProvider()),
        ChangeNotifierProvider(create: (_) => AdminOfferProvider()),
        ChangeNotifierProvider(create: (_) => AdminUserProvider()),
        ChangeNotifierProvider(create: (_) => AdminStatsProvider()),
        ChangeNotifierProvider(create: (_) => AdminBrandProvider()),
        ChangeNotifierProvider(create: (_) => AdminSettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Shopping Admin Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E2022)),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // 1. Check if user is authenticated
            if (auth.isAuthenticated) {
              return const MainScreen();
            }

            // 2. Try Auto Login on app load (SharedPreferences check)
            return FutureBuilder<bool>(
              future: auth.tryAutoLogin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return const MainScreen();
                }

                return const AdminLoginScreen();
              },
            );
          },
        ),
      ),
    );
  }
}