import 'package:nurebo_admin/models/business.dart';

class BusinessSetting {
  Business? business;
  int? email_notification;
  int? chat_notification;


  BusinessSetting({
    this.business,
    this.chat_notification,
    this.email_notification,
  });

  factory BusinessSetting.fromJson(Map<String, dynamic> json) => BusinessSetting(
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
    // data['business_id'] = id;
    // data['business_name'] = name;
    // data['max_contemporary_appointments'] = max_contemporary_appointments;
    // data['business_address'] = address;
    // data['business_email'] = email;
    // data['business_is_app'] = is_app;
    // datae['business_profile_image'] ?? '' = profile_image;
    // data['business_phone_number'] = phone_number;
    // data['business_type_id'] = type_id;
    // data['business_description'] = description;
    return data;
  }
}

