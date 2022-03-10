import 'dart:convert';

AppUser appUserFromJson(String str) => AppUser.fromJson(json.decode(str));

String appUserToJson(AppUser data) => json.encode(data.toJson());

class AppUser {
  int id;
  String authKey;
  String name;
  String image;
  String email;
  int usertype;
  int status;
  String emailVerifiedAt;
  String createdAt;
  String updatedAt;
  String instagramUrl;
  String facebookUrl;
  String youtubeUrl;
  String pinterestUrl;
  int followingCount;
  int followersCount;

  AppUser({
    this.id,
    this.authKey,
    this.name,
    this.image,
    this.email,
    this.usertype,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.instagramUrl,
    this.facebookUrl,
    this.youtubeUrl,
    this.pinterestUrl,
    this.followingCount,
    this.followersCount,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        usertype: json["usertype"] != null ? json["usertype"] : null,
        status: json["status"] != null ? json["status"] : null,
        emailVerifiedAt: json["email_verified_at"] != null
            ? json["email_verified_at"]
            : null,
        image: json["image"] != null ? json["image"] : null,
        instagramUrl:
            json["instragramUrl"] != null ? json["instragramUrl"] : null,
        facebookUrl: json["facebookUrl"] != null ? json["facebookUrl"] : null,
        pinterestUrl:
            json["pinterestUrl"] != null ? json["pinterestUrl"] : null,
        youtubeUrl: json["youtubeUrl"] != null ? json["youtubeUrl"] : null,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        followingCount:
            json["following_count"] != null ? json["following_count"] : null,
        followersCount:
            json["followers_count"] != null ? json["followers_count"] : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "image": image,
        "status": status,
        "usertype": usertype,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
