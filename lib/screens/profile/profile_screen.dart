import 'package:blog_forum/providers/profile_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.fetchCurrentProfile();
      if (profileProvider.profile != null) {
        _nameController.text = profileProvider.profile!.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = Supabase.instance.client.auth.currentUser;

    void onHandleImageUpload() async {
      await profileProvider.uploadAvatar();
      if (!context.mounted) return;

      if (profileProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            showCloseIcon: true,
            duration: Duration(seconds: 5),
            content: StyledText('Failed uploading avatar'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            showCloseIcon: true,
            duration: Duration(seconds: 5),
            content: StyledText('Avatar uploaded successfully'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.topLeft,
          child: const StyledTitle('Profile'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {context.go('/');},
              child: const Center(
                child: StyledHeading('Home'),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: profileProvider.isLoading || profileProvider.profile == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            if (profileProvider.isLoading || profileProvider.profile == null)
                 CircularProgressIndicator(
                  color: AppColors.titleColor,
              )
            else if (profileProvider.errorMessage != null)
              StyledText(profileProvider.errorMessage!)
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: onHandleImageUpload,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.textColor,
                        backgroundImage: profileProvider.profile?.avatarUrl != null
                            ? NetworkImage(profileProvider.profile!.avatarUrl!)
                            : null,
                        child: profileProvider.profile?.avatarUrl == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 10),
                    StyledTitle(profileProvider.profile!.name),
                    const SizedBox(height: 10),
                    StyledText('${user!.email}'),

                    const SizedBox(height: 100),

                    const Align(
                      alignment: Alignment.topLeft,
                      child: StyledTitle('Update Profile'),
                    ),

                    const SizedBox(height: 16),

                    StyledTextField(
                      controller: _nameController,
                      label: 'Name',
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)
                          ),
                          backgroundColor: AppColors.secondaryColor,
                        ),
                        onPressed: () async {
                          await profileProvider.updateProfile(
                            name: _nameController.text.trim(),
                          );

                          if (!context.mounted) return;

                          if(profileProvider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                showCloseIcon: true,
                                duration: Duration(seconds: 5),
                                content: StyledText("Failed updating profile"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                showCloseIcon: true,
                                duration: Duration(seconds: 5),
                                content: StyledText('Profile updated successfully'),
                              ),
                            );
                          }
                        },
                        child: !profileProvider.isLoading
                            ? StyledText('Save')
                            : StyledText('Saving...'),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}