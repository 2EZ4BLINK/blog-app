import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/providers/post_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  Future<void> _onHandleUpdatePost() async {
    final postProvider = context.read<PostProvider>();

    await postProvider.updatePost(
      postId: widget.post.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    if (!context.mounted) return;

    if(postProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 5),
          content: StyledText('Failed updating post'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 5),
          content: StyledText('Post updated'),
        ),
      );
    }

    if (postProvider.errorMessage == null) {
      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.post.title,
    );

    _contentController = TextEditingController(
      text: widget.post.content,
    );
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
        title: const StyledTitle('Edit Post'),
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
              label: 'Content',
              maxLine: 5,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: postProvider.isLoading
                    ? null
                    : _onHandleUpdatePost,
                child: postProvider.isLoading
                    ? const StyledText('Updating Post...')
                    : const StyledText('Update Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}