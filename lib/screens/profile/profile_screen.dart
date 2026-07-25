import 'package:blog_forum/providers/post_provider.dart';
import 'package:blog_forum/providers/profile_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProfileProvider>().fetchCurrentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle('Profile'),
      ),
      body: Center(
        child: Column(
          children: [
            if(profileProvider.isLoading)
              CircularProgressIndicator()
            else if (profileProvider.errorMessage != null)
              StyledText(profileProvider.errorMessage!)
            else
              StyledText(profileProvider.profile!.name)
          ],
        ),
      ),
    );
  }
}