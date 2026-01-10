import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';

class Post {
  String? id;
  Business? business;
  // Booking? booking;
  Prestazione? prestazione;
  String? image_url;
  DateTime? created_at;
  String? description;
  // int? is_admin;
  int? is_visible;
  // String? title;
  User? user;

  Post({
    this.description,
    this.image_url,
    this.id,
    // this.booking,
    // this.is_admin,
    this.is_visible,
    this.business,
    this.prestazione,
    // this.title,
    this.created_at,
    this.user,
  });
}
