import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nurebo_admin/main.dart';

class Utils {
  static final String httpServerUrl = "http://192.168.1.13:5000/";
  // static const String httpServerUrl = "https://api.nurebo.com/";
  // static const String httpServerUrl = "https://clexira.online/";
  // static const String httpServerUrl = "https://dev.nurebo.com/";
  // static final String httpServerUrl = "http://192.168.1.225:6000/api/v1/";
  // static const String httpServerUrl = "https://dev.nurebo.com/api/v1/";
  // static const String httpServerUrl = "https://api.nurebo.com/api/v1/";
  // static const String httpServerUrl = "https://www.pleunia.com/";
  // static const String httpServerUrl = "https://www.pleunia.com/api/v1/";
  // static final String httpServerUrl = "kadingira-lb-999907811.eu-central-1.elb.amazonaws.com/";
  // static int connectedSockets = 0;
  static const version_id = 197;
  static final version_name = '0.1.8';
  static final bool isDev = true;
  static const int maxCampaignPerWeek = 2;
  // static final version_name = packageInfo.version;
  static String businessChatRoomOpen = "";
  static int timezoneOffset = DateTime.now().timeZoneOffset.inHours;

}