import 'package:nurebo_admin/models/user.dart';

class UserDevice {
  String? id;
  String? fcm_token;
  String? manufacturer;
  String? model;
  String? os;
  String? release_version;
  int? sdk_version;
  User? user;
  DateTime? created_at;
  int? is_open;

  UserDevice({
    this.id,
    this.manufacturer,
    this.model,
    this.user,
    this.fcm_token,
    this.created_at,
    this.os,
    this.release_version,
    this.sdk_version,

    this.is_open,
  });

  // factory UserDevice.fromJson(Map<String, dynamic> json) => UserDevice(
  //   username: json['username'],
  //   email: json['email'],
  //   profile_image: json['profile_image'],
  //   password: json['password'],
  //   city: json['city'],
  //   description: json['description'],
  //   first_name: json['first_name'],
  //   last_name: json['last_name'],
  //   // phone_number: int.parse(json['phone_number']),
  //   phone_number: json['phone_number'],
  //   id: json['id'],
  //   last_login: DateTime.tryParse(json['last_login']),
  // );

  Map<String, dynamic> toJson() => {
    'id': id,
    'model': model,
    'manufacturer': manufacturer,
    'fcm_token': fcm_token,
    // 'device_os': ,
    'sdk_version': sdk_version,
    'release_version': release_version,
    'user': user!.toJson(),
    'created_at': created_at.toString(),
  };
}
