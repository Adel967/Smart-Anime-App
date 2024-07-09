  import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';

late Color textColor;
late Color backgroundColor;
late bool backgroundDownload;

saveParentalControlData()async{
  final parentalControl = await SQLiteHelper.instance.readParentalControl();
  final blockedAnimes = await SQLiteHelper.instance.readBlockedAnime();
  final rules = await SQLiteHelper.instance.readRule();

  List<String> rule = [];
  rules.forEach((element) {
    String r = "${element.weekDay}.${element.durationUsage.trim()}.${element.epNum}.${element.active}";
    rule.add(r);
  });


  Services.updateParentalControl(parentalControl["password"], parentalControl["openTime"] == null ? "" : parentalControl["openTime"], parentalControl["closeTime"] == null ? "" : parentalControl["closeTime"], parentalControl["blockedCategories"] == null ? "" : parentalControl["blockedCategories"],blockedAnimes.isNotEmpty ? blockedAnimes.join(",") : "",rule.isNotEmpty ?  rule.join(",") : "");
}