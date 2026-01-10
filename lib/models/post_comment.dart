import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/user.dart';

class PostComment {
  String? id;
  String? text;
  User? user;
  // Post? post;
  BusinessPost? businessPost;
  DateTime? created_at;
  // bool isLiked;
  int? is_admin;

  PostComment({
    this.user,
    this.id,
    this.created_at,
    this.text,
    // this.post,
    this.businessPost,
    this.is_admin,
  });

}