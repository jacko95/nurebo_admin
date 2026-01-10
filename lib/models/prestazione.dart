import 'business.dart';

class Prestazione {
  String? id;
  String? previous_prestazione;
  String? business_id;
  String? title;
  String? image;
  double? price;
  double? price_min;
  double? price_max;
  bool is_price_range;
  int? duration;
  int? is_valid;
  String? description;
  DateTime? created_at;
  Business? business;

  Prestazione({
    this.description,
    this.is_valid,
    this.previous_prestazione,
    this.duration,
    this.created_at,
    this.id,
    required this.is_price_range,
    this.price,
    this.price_min,
    this.price_max,
    this.title,
    this.business_id,
    this.image,
    this.business,
  });

  // factory Prestazione.fromJson(Map<String, dynamic> json) => Prestazione(
  //   // id: json['title'],
  //   // text: json['performer_name'],
  //   // prestazione: json['image'],
  //   // // is_prestazione_sender: int.parse(json['event_prestazione_id']),
  //   // sent_at: json['description'],
  //   // is_deleted: int.parse(json['performer_profile_id']),
  //   // user: json['id'],
  //   // single_event: json['id'],
  // );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prestazione_id'] = id;
    data['prestazione_title'] = title;
    data['prestazione_description'] = description;
    data['prestazione_price'] = price;
    data['prestazione_price_min'] = price_min;
    data['prestazione_price_max'] = price_max;
    data['prestazione_duration'] = duration;
    data['prestazione_image'] = image;
    business!.toJson();
    return data;
  }
}
