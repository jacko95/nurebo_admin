import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/models/post_like.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';


class BusinessPost {
  String? id;
  Business? business;
  Prestazione? prestazione;
  // Business business;
  String? image_url;
  // String? title;
  // int? is_video;
  int? is_visible;
  List<PostComment> comments = [];
  List<PostLike> likes = [];
  DateTime? created_at;
  String? description;
  User? user;

  BusinessPost({
    this.description,
    this.business,
    this.prestazione,
    this.id,
    this.image_url,
    required this.likes,
    required this.comments,
    this.created_at,
    // this.title,
    this.user,
    this.is_visible,
    // this.is_video,
  });
}
