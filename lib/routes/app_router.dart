import 'package:blog_forum/providers/auth_provider.dart';
import 'package:blog_forum/screens/auth/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const Set<String> publicRoutes = {
  '/login',
};


final router = GoRouter(
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();

    final isLoggedIn = authProvider.isLoggedIn;
    final currentRoute = state.matchedLocation;
    final isPublicRoute = publicRoutes.contains(currentRoute);

    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    return null;
  },
  routes: [
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) {
    //     return const BlogListScreen();
    //   },
    // ),
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
  ],
);