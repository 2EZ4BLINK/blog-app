import 'dart:io';

import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/models/post_image.dart';
import 'package:blog_forum/providers/post_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({
    super.key,
    required this.post,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<File> _newImages = [];
  late List<PostImage> _existingImages;

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

  Future<void> _onHandleUpdatePost() async {
    final postProvider = context.read<PostProvider>();

    await postProvider.updatePost(
      postId: widget.post.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      originalImages: widget.post.images,
      existingImages: _existingImages,
      newImages: _newImages,
    );

    if (!mounted) return;

    if (postProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Failed updating post'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Post updated'),
        ),
      );

      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();

    _existingImages = List.from(widget.post.images);
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
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
                          ),
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