import 'dart:io';

import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/providers/comment_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:blog_forum/models/comment_image.dart';
import 'package:image_picker/image_picker.dart';

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

  final List<File> _newImages = [];
  late List<CommentImage> _existingImages;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isEmpty) return;

    setState(() {
      _newImages.addAll(
        selectedImages.map((image) => File(image.path)),
      );
    });
  }

  Future<void> _onHandleUpdateComment() async {
    final commentProvider = context.read<CommentProvider>();
    if (_commentController.text.trim().isEmpty) return;

    await commentProvider.updateComment(
      postId: widget.post.id,
      commentId: widget.comment.id,
      content: _commentController.text.trim(),
      originalImages: widget.comment.images,
      existingImages: _existingImages,
      newImages: _newImages,
    );

    if(!mounted) return;

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
      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.comment.content;
    _existingImages = List.from(widget.comment.images);
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
            if (_existingImages.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImages.length,
                  itemBuilder: (context, index) {
                    final image = _existingImages[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Image.network(
                            image.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.secondaryAccent,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.titleColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _existingImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_newImages.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Image.file(
                            _newImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.secondaryAccent,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.titleColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _newImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            StyledTextField(
              controller: _commentController,
              label: 'Comment',
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  overlayColor: AppColors.textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: _pickImages,
                child: const StyledText('Select Images'),
              ),
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
                    : _onHandleUpdateComment,
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
