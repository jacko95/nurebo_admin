
class BusinessCampaignType {
  int id;
  String? icon;
  double? icon_size;
  String? title;
  String? description;
  DateTime? created_at;

  BusinessCampaignType({
    required this.id,
    this.icon,
    this.icon_size,
    this.description,
    this.title,
    this.created_at,
  });
}

