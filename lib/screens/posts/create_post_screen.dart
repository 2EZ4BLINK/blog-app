import 'dart:io';

import 'package:blog_forum/providers/post_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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

  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    final _picker = ImagePicker();
    final List<XFile> images = await _picker.pickMultiImage();

    setState(() {
      _selectedImages = images
          .map((image) => File(image.path))
          .toList();
    });
  }

  Future<void> _onHandleCreatePost() async {
    final trimmedTitle = _titleController.text.trim();
    final trimmedContent = _contentController.text.trim();

    if(trimmedTitle.isEmpty || trimmedContent.isEmpty) return;

    final postProvider = context.read<PostProvider>();

    final postId = await postProvider.createPost(
      title: trimmedTitle,
      content: trimmedContent,
    );

    if (postId == null) return;

    if(_selectedImages.isNotEmpty)  {
      await postProvider.uploadPostImages(
        postId: postId,
        images: _selectedImages,
      );
    }

    if (!mounted) return;

    if(postProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Failed creating post'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Post created'),
        ),
      );
    }

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
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          Image.file(
                            _selectedImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 20),

                        ]
                      ),
                    );
                  },
                ),
              ),
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