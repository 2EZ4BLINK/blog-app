import 'package:blog_forum/providers/auth_provider.dart';
import 'package:blog_forum/routes/app_router.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sdtzgsyfzfrojnbtpirr.supabase.co',
    publishableKey: 'sb_publishable_tN6GUeWgpEiDLAZEF4CC9A_LQh_WeH0',
  );

  final authProvider = AuthProvider();
  final router = createRouter(authProvider);

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.router,
    super.key,
  });

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: defaultTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}