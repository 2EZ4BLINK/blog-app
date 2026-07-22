import 'package:blog_forum/routes/app_router.dart';
import 'package:blog_forum/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:blog_forum/theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blog_forum/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sdtzgsyfzfrojnbtpirr.supabase.co',
    publishableKey: 'sb_publishable_tN6GUeWgpEiDLAZEF4CC9A_LQh_WeH0',
  );

  runApp(ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: defaultTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}