import 'dart:io';

import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/providers/comment_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) return;

    setState(() {
      _selectedImages.addAll(
        images.map((image) => File(image.path)),
      );
    });
  }

  Future<void> _onHandlePostComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final commentProvider = context.read<CommentProvider>();
    await commentProvider.createComment(
      postId: widget.post.id,
      content: _commentController.text.trim(),
      images: _selectedImages,
    );

    if (!mounted) return;

    if (commentProvider.errorMessage == null) {
      _commentController.clear();
      setState(() {
        _selectedImages.clear();
      });
    }
  }

  Future<void> _onHandleDeleteComment(Comment comment) async {
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

  Future<void> _onHandleEditComment(Comment comment) async {
    context.push('/edit-comment', extra: {
      'post': widget.post,
      'comment': comment
    });
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
            if (widget.post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.post.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.network(
                        widget.post.images[index].imageUrl,
                        width: MediaQuery.of(context).size.width - 32,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            StyledHeading(widget.post.title),
            const SizedBox(height: 8),
            StyledText(widget.post.content),
            const SizedBox(height: 40),

            StyledTitle('Comments'),
            const SizedBox(height: 12),
            Divider(color: AppColors.textColor),
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
                            if (comment.images.isNotEmpty) ...[
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: comment.images.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Image.network(
                                        comment.images[index].imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            StyledText(comment.content),
                            if (comment.authorId == user!.id)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () => _onHandleEditComment(comment),
                                    color: AppColors.titleColor,
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () => _onHandleDeleteComment(comment),
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

            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: StyledTextField(
                    controller: _commentController,
                    label: 'Write a comment',
                  ),
                ),

                const SizedBox(width: 8),

                OutlinedButton(
                  onPressed: _pickImages,
                  style: OutlinedButton.styleFrom(
                    overlayColor: AppColors.textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(48, 48),
                  ),
                  child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textColor
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: commentProvider.isLoading
                      ? null
                      : _onHandlePostComment,
                  style: OutlinedButton.styleFrom(
                    overlayColor: AppColors.textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(48, 48),
                  ),
                  child: Icon(
                      Icons.send_rounded,
                      color: AppColors.textColor
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}