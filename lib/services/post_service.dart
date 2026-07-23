import 'package:blog_forum/config/supabase_config.dart';
import 'package:blog_forum/models/post.dart';

class PostService {
  Future<List<Post>> fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    List<Post> posts = response.map((json) => Post.fromJson(json)).toList();

    return posts;
  }
}