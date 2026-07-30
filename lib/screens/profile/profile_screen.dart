import 'package:blog_forum/providers/profile_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _loadProfile() async {
    final profileProvider = context.read<ProfileProvider>();

    await profileProvider.fetchCurrentProfile();

    if (!mounted) return;

    if (profileProvider.profile != null) {
      _nameController.text = profileProvider.profile!.name;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
    final ImagePicker picker = ImagePicker();

    void onHandleImageUpload() async {
      final messenger = ScaffoldMessenger.of(context);

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      await profileProvider.uploadAvatar(image);

      if (!mounted) return;

      if (profileProvider.errorMessage != null) {
        messenger.showSnackBar(
          const SnackBar(
            showCloseIcon: true,
            duration: Duration(seconds: 3),
            content: StyledText('Failed uploading avatar'),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            showCloseIcon: true,
            duration: Duration(seconds: 3),
            content: StyledText('Avatar uploaded successfully'),
          ),
        );
      }
    }

    void onHandleUpdateName() async {
      final messenger = ScaffoldMessenger.of(context);

      await profileProvider.updateProfile(
        name: _nameController.text.trim(),
      );

      if (!mounted) return;

      if(profileProvider.errorMessage != null) {
        messenger.showSnackBar(
          const SnackBar(
            showCloseIcon: true,
            duration: Duration(seconds: 3),
            content: StyledText("Failed updating name"),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            showCloseIcon: true,
            duration: Duration(seconds: 3),
            content: StyledText('Name updated successfully'),
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
              child: TextButton(
                  onPressed: () => context.go('/'),
                  style: TextButton.styleFrom(overlayColor: AppColors.textColor),
                  child: StyledHeading('Home'),

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
                   InkWell(
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
                          overlayColor: AppColors.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)
                          ),
                          backgroundColor: AppColors.secondaryColor,
                        ),
                        onPressed: onHandleUpdateName,
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