import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_campaign_type.dart';

class BusinessCampaign {
  String id;
  BusinessCampaignType business_campaign_type;
  Business? business;
  DateTime? created_at;

  BusinessCampaign({
    required this.id,
    required this.business_campaign_type,
    this.business,
    this.created_at,
  });
}

