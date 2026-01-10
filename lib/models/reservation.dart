import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/reservation_proposal.dart';

class Reservation {
  String? id;
  Business? business;
  String? name;
  DateTime? datetime;
  DateTime? created_at;
  ReservationProposal? proposal;
  int? quantity;
  String? email;
  String? user_url;
  String? business_url;
  // String? description;
  String? info;
  String? phone;
  bool? is_canceled;
  // bool? is_validated;
  DateTime? is_canceled_at;
  DateTime? validated_at;
  DateTime? last_edit_at;


  Reservation({
    this.id,
    this.proposal,
    this.business_url,
    this.created_at,
    this.datetime,
    this.quantity,
    this.last_edit_at,
    this.user_url,
    this.name,
    this.business,
    this.info,
    this.phone,
    this.email,
    this.is_canceled,
    this.is_canceled_at,
    // this.is_validated,
    this.validated_at,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours));
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['reservation_id']?.toString(),
      business: Business(
        id: json['business_id']?.toString(),
        name: json['business_name']?.toString(),
        profile_image: json['business_image_url']?.toString(),
        phone: json['business_phone']?.toString(),
        email: json['business_email']?.toString(),
        address: json['business_address']?.toString(),
      ),
      name: json['reservation_name']?.toString(),
      datetime: _parseDateTime(json['reservation_datetime_datetime']),
      last_edit_at: _parseDateTime(json['sort_timestamp']),
      created_at: _parseDateTime(json['reservation_created_at']),
      validated_at: _parseDateTime(json['reservation_validation_created_at']),
      proposal: json['reservation_proposal_id'] != null
          ? ReservationProposal.fromJson(json)
          : null,
      quantity: (json['reservation_quantity'] as int?) ?? 0,
      email: json['reservation_email']?.toString(),
      user_url: json['reservation_user_url']?.toString(),
      business_url: json['reservation_business_url']?.toString(),
      phone: json['reservation_phone']?.toString(),
      info: json['business_info']?.toString(),
      is_canceled: json['reservation_cancel_created_at'] != null,
      is_canceled_at: _parseDateTime(json['reservation_cancel_created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_id': id,
      'business_id': business?.id,
      'business_name': business?.name,
      'business_image_url': business?.profile_image,
      'business_phone': business?.phone,
      'business_email': business?.email,
      'business_address': business?.address,
      'reservation_name': name,
      'reservation_datetime_datetime': datetime?.toIso8601String(),
      'sort_timestamp': last_edit_at?.toIso8601String(),
      'reservation_created_at': created_at?.toIso8601String(),
      'reservation_validation_created_at': validated_at?.toIso8601String(),
      'reservation_proposal_id': proposal?.id,
      'reservation_proposal_user_type_id': proposal?.user_type_id,
      'reservation_proposal_created_at': proposal?.created_at?.toIso8601String(),
      'reservation_quantity': quantity,
      'reservation_email': email,
      'reservation_user_url': user_url,
      'reservation_business_url': business_url,
      'reservation_phone': phone,
      'business_info': info,
      'reservation_cancel_created_at': is_canceled_at?.toIso8601String(),
    };
  }
}

