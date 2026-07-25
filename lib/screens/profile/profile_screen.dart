import 'package:blog_forum/providers/profile_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      _nameController.text = profileProvider.profile!.name;
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    StyledText(
                      'User: ${profileProvider.profile!.name}',
                    ),

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

                    ElevatedButton(
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
                              duration: Duration(seconds: 5),
                              showCloseIcon: true,
                              content: StyledText("Failed updating profile"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 5),
                              showCloseIcon: true,
                              content: StyledText('Profile updated successfully'),
                            ),
                          );
                        }
                      },
                      child: const StyledText('Save'),
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