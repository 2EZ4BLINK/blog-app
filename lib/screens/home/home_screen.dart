import 'package:blog_forum/providers/auth_provider.dart';
import 'package:blog_forum/providers/post_provider.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _onHandleDeletePost(String postId) async {
    final postProvider = context.read<PostProvider>();

    await postProvider.deletePost(postId);

    if (!mounted) return;

    if (postProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Failed deleting post'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Post deleted'),
        ),
      );
    }
  }

  Future<void> _onHandleSignOut() async {
    await context.read<AuthProvider>().signOut();

    if (!mounted) return;

    context.go('/');
  }

  Future<void> _onHandleLoadMore() async {
    await context.read<PostProvider>().fetchPosts();
  }

  @override
  void initState() {
    super.initState();

    context.read<PostProvider>().fetchPosts(
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthProvider>();

    final postProvider = context.watch<PostProvider>();
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: StyledTitle('Home'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (user == null) return;

              context.go('/profile');
            },
            style: TextButton.styleFrom(
              overlayColor: AppColors.textColor,
            ),
            child: StyledText(user?.email ?? 'Guest'),
          ),
          if (user == null)
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                overlayColor: AppColors.textColor,
              ),
              child: const StyledHeading('Login'),
            )
          else
            TextButton(
              onPressed: _onHandleSignOut,
              style: TextButton.styleFrom(
                overlayColor: AppColors.textColor,
              ),
              child: const StyledHeading('Logout'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: postProvider.isLoading && postProvider.posts.isEmpty
            ? Center(child: CircularProgressIndicator(color: AppColors.textColor))
            : postProvider.errorMessage != null && postProvider.posts.isEmpty
            ? Center(child: StyledText(postProvider.errorMessage!))
            : postProvider.posts.isEmpty
            ? const Center(child: StyledText('Start creating a post.'))
            : ListView.builder(
          itemCount: postProvider.posts.length + 1,
          itemBuilder: (context, index) {
            if (index == postProvider.posts.length) {
              if (!postProvider.hasMore) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: postProvider.isLoading
                        ? null
                        : _onHandleLoadMore,
                    style: OutlinedButton.styleFrom(
                      overlayColor: AppColors.textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: postProvider.isLoading
                        ? const StyledText('Loading...')
                        : const StyledText('Load More'),
                  ),
                ),
              );
            }

            final post = postProvider.posts[index];
            final isOwner = user?.id == post.authorId;

            return Card(
              child: InkWell(
                onTap: () {
                  context.push(
                    '/post-details',
                    extra: post,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.images.isNotEmpty) ...[
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: post.images.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, imageIndex) {
                              final image = post.images[imageIndex];

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    image.imageUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                      StyledTitle(post.title),
                      const SizedBox(height: 15),
                      StyledText(post.content),
                      if (isOwner)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              color: AppColors.titleColor,
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                context.push(
                                  '/edit-post',
                                  extra: post,
                                );
                              },
                            ),
                            IconButton(
                              color: AppColors.titleColor,
                              icon: const Icon(Icons.delete),
                              onPressed: () => _onHandleDeletePost(post.id),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
        backgroundColor: AppColors.titleColor,
        onPressed: () => context.push('/create-post'),
        icon: Icon(
          Icons.add,
          color: AppColors.secondaryAccent,
        ),
        label: StyledText(
          'Create Post',
          color: AppColors.secondaryAccent,
        ),
      ),
    );
  }
}