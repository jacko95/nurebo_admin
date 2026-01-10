import 'package:nurebo_admin/models/business_setting.dart';
import 'package:nurebo_admin/models/category.dart';

class Business {
  String? id;
  String? name;
  String? profile_image;
  String? address;
  String? province;
  String? region;
  String? nation;
  String? city;
  String? postal_code;
  String? address_number;
  String? email;
  String? description;
  String? phone;
  String? room_id;
  String? fcm_token;
  // int? is_booking_business;
  int? email_notification;
  int? type_id;
  int? is_app;
  int? max_contemporary_appointments;
  Category? category;
  double? latitude;
  double? longitude;
  List? bookingBusinessTimetable = [];
  BusinessSetting? businessSetting;

  Business({
    this.id,
    this.name,
    this.profile_image,
    this.address,
    this.email,
    this.address_number,
    this.city,
    this.nation,
    this.postal_code,
    this.province,
    this.region,
    this.description,
    this.is_app,
    this.phone,
    this.room_id,
    this.max_contemporary_appointments,
    // this.is_booking_business,
    this.type_id,
    this.category,
    this.fcm_token,
    this.longitude,
    this.latitude,
    this.bookingBusinessTimetable,
    this.email_notification,
    this.businessSetting,
  });

  factory Business.fromJson(Map<String, dynamic> json) => Business(
    // id: json['title'],
    // text: json['performer_name'],
    // business: json['image'],
    // // is_business_sender: int.parse(json['event_business_id']),
    // sent_at: json['description'],
    // is_deleted: int.parse(json['performer_profile_id']),
    // user: json['id'],
    // single_event: json['id'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_id'] = id;
    data['business_name'] = name;
    data['max_contemporary_appointments'] = max_contemporary_appointments;
    data['business_address'] = address;
    data['business_email'] = email;
    data['business_is_app'] = is_app;
    data['business_profile_image'] = profile_image;
    data['business_phone'] = phone;
    data['business_type_id'] = type_id;
    data['business_description'] = description;
    return data;
  }
}

