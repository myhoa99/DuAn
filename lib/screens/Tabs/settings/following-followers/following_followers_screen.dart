import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/screens/Tabs/settings/following-followers/users-follow/user_follow_screen.dart';
import 'package:food_recipes/widgets/user_list_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FollowingFollowersScreen extends StatefulWidget {
  final int index;

  FollowingFollowersScreen({this.index});

  @override
  _FollowingFollowersScreenState createState() =>
      _FollowingFollowersScreenState();
}

class _FollowingFollowersScreenState extends State<FollowingFollowersScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.index,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(_authProvider.user.name,
          style: TextStyle(color: Colors.black, fontFamily: 'Brandon')),
      actions: [
        _buildFollowUserButton(),
      ],
    );
  }

  _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(child: _getTabBar()),
        Expanded(child: _getTabBarPages()),
      ],
    );
  }

  _buildFollowUserButton() {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserFollowScreen()),
      ),
      icon: Icon(Icons.add),
    );
  }

  _getTabBar() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          labelStyle: TextStyle(fontFamily: 'Brandon'),
          indicatorWeight: 3,
          tabs: [
            Tab(text: "${auth.followerUsers.length}  " + "followers".tr()),
            Tab(text: "${auth.followingUsers.length}  " + "following".tr()),
          ],
        );
      },
    );
  }

  _getTabBarPages() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return TabBarView(
          controller: _tabController,
          children: <Widget>[
            (auth.followerUsers.length == 0)
                ? Container(
                    child: Center(
                      child: Text(
                        'you_have_no_followers'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pacifico(),
                      ),
                    ),
                  )
                : _followersFollowingList(context, auth.followerUsers),
            (auth.followingUsers.length == 0)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Center(
                      child: Text(
                        'you_are_not_following'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pacifico(),
                      ),
                    ),
                  )
                : _followersFollowingList(context, auth.followingUsers)
          ],
        );
      },
    );
  }

  _followersFollowingList(BuildContext context, List<AppUser> users) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserListItem(user: users[index]);
      },
    );
  }
}
