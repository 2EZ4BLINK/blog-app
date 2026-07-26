import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _contentController =
  TextEditingController();

  void _onHandleCreatePost() async {
    final postProvider = context.read<PostProvider>();

    await postProvider.createPost(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    if (!context.mounted) return;


    if (postProvider.errorMessage == null) {
      _titleController.clear();
      _contentController.clear();

      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
          title: const StyledTitle('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StyledTextField(
              controller: _titleController,
              label: 'Title',
            ),
            const SizedBox(height: 16),
            StyledTextField(
              controller: _contentController,
              maxLine: 5,
              label: 'Content',
            ),
            const SizedBox(height: 16),
            if (postProvider.errorMessage != null)
              Text(postProvider.errorMessage!),
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
                onPressed: postProvider.isLoading
                    ? null
                    : _onHandleCreatePost,
                child: postProvider.isLoading
                    ? const StyledText('Creating Post...')
                    : const StyledText('Create Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}