import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';

import 'business.dart';

class Booking {
  // String id;
  int? type;//0 = disonibile, 1 = bloccato, 2 = prenotato da un utente
  // String business_id;
  DateTime? begin_at;
  DateTime? end_at;
  int? is_guest;
  Prestazione? prestazione;
  Business? business;
  DateTime? created_at;
  // String user_id;
  // String username;
  // String user_image;
  String? note;
  // double price;
  int? is_paid;
  // User user;
  String? id;
  String? user_id;
  // Prestazione prestazione;
  // bool isPaid;
  int? isCanceled;
  String? guestName;
  String? guestEmail;
  String? guestPhone;
  User user = User(
    profile_image: ''
  );

  Booking({
    this.id,
    this.user_id,
    // // this.title,
    this.type,
    this.is_paid,
    this.isCanceled,
    this.is_guest,
    required this.user,
    // // this.price,
    // this.prestazione,
    // // this.username,
    // this.user,
    // this.business_id,
    this.created_at,
    this.guestEmail,
    this.guestPhone,
    this.guestName,
    // // this.duration,
    this.note,
    this.prestazione,
    this.business,
    // // this.user_image,
    this.begin_at,
    this.end_at,
  });

  // factory Booking.fromJson(Map<String, dynamic> json) => Booking(
  //   // id: json['title'],
  //   // text: json['performer_name'],
  //   // business: json['image'],
  //   // // is_business_sender: int.parse(json['event_business_id']),
  //   // sent_at: json['description'],
  //   // is_deleted: int.parse(json['performer_profile_id']),
  //   // user: json['id'],
  //   // single_event: json['id'],
  // );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    id = data['booking_id'];
    isCanceled = data['is_canceled'];
    // guestName: e['guest_name'],
    // guestEmail: e['guest_contact'],
    is_guest = 0;
    type = data['booking_type'];
    // note: myAppointments[index]['note'],
    // user_id: myAppointments[index]['user_id'].toString(),
    prestazione = Prestazione(
      duration: data['prestazione_duration'],
      id: data['prestazione_id'],
      image: data['prestazione_image'],
      is_price_range: (data['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
      price: data['prestazione_price']?.toDouble(),
      price_min: data['prestazione_price_min']?.toDouble(),
      price_max: data['prestazione_price_max']?.toDouble(),
      title: data['prestazione_title'],
      description: data['prestazione_description'],
      business_id: data['prestazione_business_id'],
    );
    user = User(
      id: data['user_id'],
      email: data['user_email'],
      username: data['user_username'],
      name: data['user_name'],
      description: data['user_description'],
      // phone_number: data['user_phone_number'],
      profile_image: data['user_profile_image'] ?? '',
    );
    begin_at = DateTime.tryParse(data['begin_at']);
    end_at = DateTime.tryParse(data['begin_at'])!.add(Duration(minutes: data['prestazione_duration']?.toInt()));
    created_at = DateTime.tryParse(data['created_at']!);
    note = data['note'];

    return data;
  }
}