// To parse this JSON data, do
//
//     final cuisine = cuisineFromJson(jsonString);

import 'dart:convert';

List<Cuisine> cuisineFromJson(String str) =>
    List<Cuisine>.from(json.decode(str).map((x) => Cuisine.fromJson(x)));

String cuisineToJson(List<Cuisine> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Cuisine {
  Cuisine({
    this.id,
    this.languageCode,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String languageCode;
  String name;
  String image;
  int status;
  DateTime createdAt;
  DateTime updatedAt;

  factory Cuisine.fromJson(Map<String, dynamic> json) => Cuisine(
        id: json["id"],
        languageCode: json["language_code"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "language_code": languageCode,
        "name": name,
        "image": image,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
