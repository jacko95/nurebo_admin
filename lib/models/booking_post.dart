import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/user.dart';


class BookingPost {
  String? id;
  Booking? booking;
  // Prestazione? prestazione;
  // Business business;
  String? image_url;
  // String? title;
  // int? is_video;
  double? vote;
  int? is_admin;
  int? is_visible;
  DateTime? created_at;
  String? description;
  User? user;

  BookingPost({
    this.description,
    this.is_admin,
    this.image_url,
    this.id,
    this.created_at,
    this.booking,
    this.user,
    this.is_visible,
    this.vote,
  });
}
