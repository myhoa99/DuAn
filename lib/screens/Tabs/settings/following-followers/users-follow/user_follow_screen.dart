import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/search_text_field.dart';
import 'package:food_recipes/widgets/shimmer_loading.dart';
import 'package:food_recipes/widgets/user_list_item.dart';
import 'package:provider/provider.dart';

class UserFollowScreen extends StatefulWidget {
  @override
  _UserFollowScreenState createState() => _UserFollowScreenState();
}

class _UserFollowScreenState extends State<UserFollowScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchKeywordController = TextEditingController();
  List<AppUser> _searchedUsers;
  AuthProvider _authProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _searchKeywordController.dispose();
  }

  _fetchUsers() async {
    FocusScope.of(context).unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _isLoading = true;
    });
    if (_searchKeywordController.text.isNotEmpty) {
      await ApiRepository.queryUserSearch(
              _searchKeywordController.text, _authProvider.user.id)
          .then((users) {
        if (users != null) {
          setState(() {
            _searchedUsers = users;
            print(users);
            _isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _searchedUsers.clear();
        _isLoading = false;
      });
    }
  }

  _onChanged() {
    if (_searchKeywordController.text.isEmpty)
      setState(() {
        _searchedUsers.clear();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'follow_someone'.tr(),
          style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(),
          _buildUsersList(),
        ],
      ),
    );
  }

  _buildSearchField() {
    return SearchTextfield(
      hintText: 'search_user_here'.tr(),
      controller: _searchKeywordController,
      suffixIconOnTap: () => _fetchUsers(),
      onChanged: () => _onChanged(),
    );
  }

  _buildUsersList() {
    if (!_isLoading) {
      if (_searchKeywordController.text.isNotEmpty) {
        if (_searchedUsers.isNotEmpty) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 6, left: 10, right: 10),
              itemCount: _searchedUsers.length,
              itemBuilder: (context, index) {
                return UserListItem(user: _searchedUsers[index]);
              },
            ),
          );
        } else {
          return _buildMessageText('no_users_found'.tr());
        }
      } else
        return _buildMessageText('start_looking_for_users'.tr());
    } else {
      return Expanded(child: ShimmerLoading(type: ShimmerType.Users));
    }
  }

  _buildMessageText(String text) {
    return Expanded(
      child: Center(
        child: Text(
          'start_looking_for_users'.tr(),
          style: TextStyle(fontFamily: 'Brandon'),
        ),
      ),
    );
  }
}
