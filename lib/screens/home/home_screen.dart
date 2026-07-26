import 'package:blog_forum/providers/auth_provider.dart';
import 'package:blog_forum/providers/post_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthProvider>();

    final postProvider = context.watch<PostProvider>();
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.topLeft,
          child: const StyledTitle('Home'),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if(user == null) return;
              context.go('/profile');
            },
            child: StyledText(user?.email ?? 'Guest'),
          ),
          if (user == null)
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const StyledHeading('Login'),
            )
          else
            TextButton(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();

                if (!context.mounted) return;
                context.go('/');
              },
              child: const StyledHeading('Logout'),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (postProvider.isLoading)
              CircularProgressIndicator(
                color: AppColors.textColor
              )
            else if (postProvider.errorMessage != null)
              StyledText(postProvider.errorMessage!)
            else
              StyledText('Posts: ${postProvider.posts.length}'),
          ],
        ),
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
          backgroundColor: AppColors.titleColor,
          onPressed: () {
            context.push('/create-post');
            },
          icon: Icon(Icons.add, color: AppColors.secondaryAccent),
          label: StyledText('Create Post', color: AppColors.secondaryAccent),
      ),
    );
  }
}