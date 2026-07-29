import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/providers/comment_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditCommentScreen extends StatefulWidget {
  final Comment comment;
  final Post post;

  const EditCommentScreen({
    super.key,
    required this.comment,
    required this.post,
  });

  @override
  State<EditCommentScreen> createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _onHandleUpdateComment(Comment comment) async {
    final commentProvider = context.read<CommentProvider>();
    if(widget.comment.content.isEmpty) return;

    await commentProvider.updateComment(
        postId: widget.post.id,
        commentId: widget.comment.id,
        content: _commentController.text
    );

    if(commentProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Failed updating comment'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Comment successfully updated'),
        ),
      );
    }
    context.pop();
  }

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
                  overlayColor: AppColors.textColor,
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: commentProvider.isLoading
                    ? null
                    : () => _onHandleUpdateComment(widget.comment),
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
