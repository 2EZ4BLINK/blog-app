import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/providers/comment_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditCommentScreen extends StatefulWidget {
  final Comment comment;

  const EditCommentScreen({
    super.key,
    required this.comment
  });

  @override
  State<EditCommentScreen> createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.comment.content;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle('Edit Comment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StyledTextField(
              controller: _commentController,
              label: 'Comment',
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
                onPressed: commentProvider.isLoading
                    ? null
                    : () {},
                child: commentProvider.isLoading
                    ? const StyledText('Updating Comment...')
                    : const StyledText('Update Comment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
