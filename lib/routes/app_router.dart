import 'package:blog_forum/providers/auth_provider.dart';
import 'package:blog_forum/screens/auth/login_screen.dart';
import 'package:blog_forum/screens/home/home_screen.dart';
import 'package:blog_forum/screens/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';

const Set<String> publicRoutes = {
  '/',
  '/login',
};

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return const ProfileScreen();
        }
      )
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final currentRoute = state.matchedLocation;
      final isPublicRoute = publicRoutes.contains(currentRoute);

      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      return null;
    },
  );
}