// To parse this JSON data, do
//
//     final lawjson = lawjsonFromJson(jsonString);

import 'dart:convert';

Lawjson lawjsonFromJson(String str) => Lawjson.fromJson(json.decode(str));

String lawjsonToJson(Lawjson data) => json.encode(data.toJson());

class Lawjson {
  Lawjson({
    this.laws,
  });

  List<Law> laws;

  factory Lawjson.fromJson(Map<String, dynamic> json) => Lawjson(
        laws: List<Law>.from(json["laws"].map((x) => Law.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "laws": List<dynamic>.from(laws.map((x) => x.toJson())),
      };
}

class Law {
  Law({
    this.title,
    this.time,
    this.history,
    this.shortdes,
  });

  String title;
  String time;
  String history;
  String shortdes;

  factory Law.fromJson(Map<String, dynamic> json) => Law(
        title: json["title"],
        time: json["time"],
        history: json["history"],
        shortdes: json["shortdes"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "time": time,
        "history": history,
        "shortdes": shortdes,
      };
}
