import 'dart:convert';

List<Difficulty> difficultyFromJson(String str) =>
    List<Difficulty>.from(json.decode(str).map((x) => Difficulty.fromJson(x)));

String difficultyToJson(List<Difficulty> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Difficulty {
  int id;
  String languageCode;
  String name;

  Difficulty({this.id, this.languageCode, this.name});

  factory Difficulty.fromJson(Map<String, dynamic> json) => Difficulty(
        id: json["id"],
        languageCode: json["language_code"],
        name: json["difficulty"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "language_code": languageCode,
        "difficulty": name,
      };
}
