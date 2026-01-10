import 'package:nurebo_admin/models/event.dart';

class EventTicket{
  String? id;
  double? price;
  String? title;
  String? additional;
  Event? event;
  int? total_seats;

  EventTicket({
    this.id,
    this.price,
    this.title,
    this.additional,
    this.total_seats,
    this.event
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'price': price,
    'title': title,
    'additional': additional,
    'total_seats': total_seats,
    'event': event?.toJson(),
  };
}