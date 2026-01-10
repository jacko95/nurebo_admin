import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_setting.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/reservation.dart';
import 'package:nurebo_admin/models/reservation_proposal.dart';

class ReservationProposalDatetime {
  String? id;
  int? priority;
  Reservation? reservation;
  ReservationProposal? reservationProposal;
  DateTime? datetime;
  DateTime? created_at;

  ReservationProposalDatetime({
    this.id,
    this.created_at,
    this.reservation,
    this.reservationProposal,
    this.datetime,
    this.priority,
  });

  factory ReservationProposalDatetime.fromJson(Map<String, dynamic> json) {
    return ReservationProposalDatetime(
      id: json['reservation_datetime_id']?.toString(),
      priority: json['reservation_datetime_priority'] as int?,
      reservation: json['reservation_id'] != null
          ? Reservation.fromJson(json)
          : null,
      reservationProposal: json['reservation_proposal_id'] != null
          ? ReservationProposal.fromJson(json)
          : null,
      datetime: _parseDateTime(json['reservation_datetime_datetime']),
      created_at: _parseDateTime(json['reservation_datetime_created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_datetime_id': id,
      'reservation_datetime_priority': priority,
      'reservation_datetime_datetime': datetime?.toIso8601String(),
      'reservation_datetime_created_at': created_at?.toIso8601String(),
      // Se reservation è obbligatorio, aggiungi i suoi campi
      ...?reservation?.toJson(),
      ...?reservationProposal?.toJson(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours));
  }
}

