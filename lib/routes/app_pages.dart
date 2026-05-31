import 'package:get/get.dart';
import 'app_routes.dart';
import '../screens/landing_page.dart';
import '../screens/home_page.dart';
import '../screens/explore_page.dart';
import '../screens/region_page.dart';
import '../screens/region_detail_page.dart';
import '../screens/story_detail_page.dart';
import '../screens/collection_page.dart';
import '../screens/info_page.dart';
import '../screens/favorit_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.LANDING, page: () => const LandingPage()),
    GetPage(name: AppRoutes.HOME, page: () => const HomePage()),
    GetPage(name: AppRoutes.EXPLORE, page: () => const ExplorePage()),
    GetPage(name: AppRoutes.REGION, page: () => const RegionPage()),
    GetPage(name: AppRoutes.REGION_DETAIL, page: () => const RegionDetailPage()),
    GetPage(name: AppRoutes.STORY_DETAIL, page: () => const StoryDetailPage()),
    GetPage(name: AppRoutes.COLLECTION, page: () => const CollectionPage()),
    GetPage(name: AppRoutes.INFO, page: () => const InfoPage()),
    GetPage(name: AppRoutes.FAVORIT, page: () => const FavoritPage()),
  ];
}
