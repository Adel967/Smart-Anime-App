import 'dart:convert';
import 'package:flutter/material.dart';

List<Episode> episodeFromJson(String str) => List<Episode>.from(json.decode(str).map((x) => Episode.fromJson(x)));

class Episode {
   Episode({
     this.views = '0',
     this.videoUrl = "",
     this.num = '0',
     this.date = "",
  });

   String views;
  final String videoUrl;
  final String num;
   String date;



  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    views:json['views'] ,
    videoUrl: json['videoUrl'],
    num: json['num'],
    date: json['date'] == null ? "" : json['date'],
  );



}
