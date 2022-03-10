import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_recipes/models/category.dart';
import 'package:food_recipes/providers/category_provider.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/grid_view_item.dart';
import 'package:food_recipes/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = '/categories';

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoryProvider _categoryProvider;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _fetchCategories();
  }

  _fetchCategories() async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchOrDisplayPaginatedCategories();
  }

  _onRefresh() async {
    await _categoryProvider.fetchPaginatedCategories(refresh: true);
    if (mounted)
      setState(() {
        _refreshController.refreshCompleted();
      });
  }

  _onLoading() async {
    await _categoryProvider.fetchPaginatedCategories(loading: true);
    if (mounted)
      setState(() {
        _refreshController.loadComplete();
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: RefreshConfiguration.copyAncestor(
        context: context,
        enableLoadingWhenFailed: true,
        headerBuilder: () => WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        footerTriggerDistance: 30,
        child: Scaffold(
          appBar: _appBar(),
          body: _body(),
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      centerTitle: true,
      brightness: Brightness.light,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        'categories'.tr(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
    );
  }

  _body() {
    return Consumer<CategoryProvider>(
      builder: (context, category, child) {
        if (category.categoryStatus == CategoryStatus.Fetching) {
          return ShimmerLoading(type: ShimmerType.Categories);
        } else {
          List<Category> _categories = category.paginatedCategories;
          return _categories.isNotEmpty
              ? SmartRefresher(
                  key: _refreshKey,
                  controller: _refreshController,
                  enablePullUp: true,
                  physics: BouncingScrollPhysics(),
                  footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: GridView(
                    key: _contentKey,
                    padding: const EdgeInsets.all(15),
                    children: _categories
                        .map((category) => GridViewItem(
                              category: category,
                              path: ApiRepository.CATEGORY_IMAGES_PATH,
                            ))
                        .toList(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'no_categories_found'.tr(),
                    style: GoogleFonts.pacifico(fontSize: 16),
                  ),
                );
        }
      },
    );
  }
}
