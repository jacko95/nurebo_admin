import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/business.dart';

class Event {
  String? id;
  String? title;
  String? previous;
  String? business_id;
  Category? category;
  String? image;
  String? description;
  // String performer_name;
  DateTime? begin_at;
  DateTime? end_at;
  DateTime? created_at;
  Business? business;
  int? is_valid;

  Event({
    this.id,
    this.image,
    this.title,
    this.previous,
    this.business_id,
    // this.performer_name,
    this.category,
    this.end_at,
    this.begin_at,
    this.description,
    this.created_at,
    this.business,
    this.is_valid,
  });


  factory Event.fromJson(Map<String, dynamic> json) => Event(
    title: json['title'],
    // performer_name: json['performer_name'],
    image: json['image'],
    // event_business_id: int.parse(json['event_business_id']),
    description: json['description'],
    // performer_profile_id: int.parse(json['performer_profile_id']),
    id: json['id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': image,
    'title': title,
    // 'performer_name': performer_name,
    'description': description,
    // 'event_business_id': event_business_id,
    // 'performer_profile_id': performer_profile_id,
  };

}