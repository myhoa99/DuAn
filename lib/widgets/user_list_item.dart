import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/screens/Other/profile/profile_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';

class UserListItem extends StatelessWidget {
  final AppUser user;

  const UserListItem({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          height: 70,
          child: Card(
            elevation: 1.5,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  _buildUserImage(),
                  SizedBox(width: 10),
                  _buildUserName(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildUserImage() {
    return (user.image != null)
        ? (user.image.contains('https'))
            ? CachedNetworkImage(
                imageUrl: '${user.image}',
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                placeholder: (context, url) =>
                    ShimmerWidget(width: 50, height: 50, circular: true),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            : CachedNetworkImage(
                imageUrl: '${ApiRepository.USER_IMAGES_PATH}${user.image}',
                imageBuilder: (context, imageProvider) => Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) =>
                    ShimmerWidget(width: 50, height: 50, circular: true),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
        : CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/logo_user.png'),
            radius: 25,
          );
  }

  _buildUserName() {
    return Text(
      user.name,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}
