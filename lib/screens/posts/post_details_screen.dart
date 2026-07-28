import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/providers/comment_provider.dart';
import 'package:blog_forum/shared/styled_button.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;

  const PostDetailsScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _onHandlePostComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final commentProvider = context.read<CommentProvider>();

    await commentProvider.createComment(
      postId: widget.post.id,
      content: _commentController.text.trim(),
    );

    _commentController.clear();
  }




  @override
  void initState() {
    super.initState();
    context
      .read<CommentProvider>()
      .fetchComments(widget.post.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const StyledHeading('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledHeading(widget.post.title),
            const SizedBox(height: 8),
            StyledText(widget.post.content),
            const SizedBox(height: 24),

            commentProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.textColor)
                )
                : commentProvider.errorMessage != null
                ? StyledText(commentProvider.errorMessage!)
                : Expanded(
                child: ListView.builder(
                  itemCount: commentProvider.comments.length,
                  itemBuilder: (context, index) {
                    final comment = commentProvider.comments[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StyledText(comment.content),

                            if (comment.authorId == currentUserId)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    color: AppColors.titleColor,
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    color: AppColors.titleColor,
                                    onPressed: () async {
                                      await commentProvider.deleteComment(
                                        postId: widget.post.id,
                                        commentId: comment.id,
                                      );
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            StyledTextField(
              controller: _commentController,
              label: 'Write a comment',
            ),

            const SizedBox(height: 16),

            StyledButton(
              onPressed: commentProvider.isLoading ? null : _onHandlePostComment,
              child: commentProvider.isLoading
                  ? const StyledText('Posting comment...')
                  : const StyledText('Post Comment'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}