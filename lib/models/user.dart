
class User {
  /*final*/String? id;
  String? username;
  String? phone;
  String? email;
  String? password;
  String profile_image = '';
  String? description;
  String? fcm_token;
  int? eventBusiness;
  int? email_notification;
  String? first_name;
  String? last_name;
  String? name;
  String? fiscal_code;
  DateTime? registration_date;
  DateTime? last_login;
  DateTime? last_logout;
  String? via;
  String? address;
  int? numero_civico;
  String? scala;
  String? city;
  int? cap;
  String? region;
  String? nation;
  int? visible;
  int? payment_card_id;
  double? latitude;
  double? longitude;


  User({
    this.id,
    this.username,
    this.email,
    this.description,
    this.password,
    this.eventBusiness,
    this.email_notification,
    this.fcm_token,
    this.address,
    this.city,
    this.visible,
    this.cap,
    this.latitude,
    this.longitude,
    this.fiscal_code,
    this.name,
    this.first_name,
    this.last_login,
    this.last_logout,
    this.last_name,
    this.nation,
    this.numero_civico,
    this.phone,
    this.payment_card_id,
    required this.profile_image,
    this.registration_date,
    this.region,
    this.scala,
    this.via,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'],
    email: json['email'],
    profile_image: json['profile_image'] ?? '',
    password: json['password'],
    city: json['city'],
    description: json['description'],
    first_name: json['first_name'],
    last_name: json['last_name'],
    // phone_number: int.parse(json['phone_number']),
    phone: json['phone'],
    id: json['id'],
    last_login: DateTime.tryParse(json['last_login']),
  );

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'user_profile_image': profile_image,
    'user_username': username,
    'user_name': name,
    'user_description': description,
    'user_email': email,
    'user_phone': phone,
  };
}
