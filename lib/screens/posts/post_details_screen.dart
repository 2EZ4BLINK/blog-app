import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/providers/comment_provider.dart';
import 'package:blog_forum/providers/profile_provider.dart';
import 'package:blog_forum/shared/styled_button.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String? _userName;

  Future<void> _onHandlePostComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final commentProvider = context.read<CommentProvider>();

    await commentProvider.createComment(
      postId: widget.post.id,
      content: _commentController.text.trim(),
    );

    _commentController.clear();
  }

  Future<void> _onHandleDeletePost(Comment comment) async {
    final commentProvider = context.read<CommentProvider>();
    await commentProvider.deleteComment(
      postId: widget.post.id,
      commentId: comment.id,
    );

    if( !mounted) return;

    if(commentProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Failed deleting comment'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Comment deleted'),
        ),
      );
    }

  }

  Future<void> _onHandleEditPost(Comment comment) async {
    context.push('/edit-comment', extra: comment);
  }

  @override
  void initState() {
    super.initState();
    context
      .read<CommentProvider>()
      .fetchComments(widget.post.id);

    Future.microtask(() async {
     final profileProvider = context.read<ProfileProvider>();
     await profileProvider.fetchCurrentProfile();
     if (!mounted) return;
     setState(() {
      _userName = profileProvider.profile!.name;
     });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final user = Supabase.instance.client.auth.currentUser;

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
            const SizedBox(height: 100),
            Divider(
              color: AppColors.textColor
            ),
            const SizedBox(height: 12),
            StyledTitle('Comments'),
            const SizedBox(height: 12),

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
                            StyledText(_userName, fontSize: 18),
                            const SizedBox(height: 24),
                            StyledText(comment.content),

                            if (comment.authorId == user!.id)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () => _onHandleEditPost(comment),
                                    color: AppColors.titleColor,
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () => _onHandleDeletePost(comment),
                                    color: AppColors.titleColor,
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
              onPressed: commentProvider.isLoading
                  ? null
                  : _onHandlePostComment,
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