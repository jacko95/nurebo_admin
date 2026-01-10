import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_setting.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/reservation.dart';

class ReservationProposal {
  String? id;
  int? user_type_id;
  Reservation? reservation;
  DateTime? created_at;

  ReservationProposal({
    this.id,
    this.created_at,
    this.reservation,
    this.user_type_id,
  });

  factory ReservationProposal.fromJson(Map<String, dynamic> json) {
    return ReservationProposal(
      id: json['reservation_proposal_id']?.toString(),
      // reservation: json['reservation_id'] != null
      //     ? Reservation.fromJson(json)
      //     : null,
      user_type_id: (json['reservation_proposal_user_type_id'] as int?) ?? 0,
      created_at: _parseDateTime(json['reservation_proposal_created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_proposal_id': id,
      'reservation_proposal_user_type_id': user_type_id,
      'reservation_proposal_created_at': created_at?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours));
  }
}

