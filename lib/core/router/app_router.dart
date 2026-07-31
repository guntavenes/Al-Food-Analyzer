import 'package:ai_food_analyzer/features/analysis/presentation/pages/food_analysis_result_page.dart';
import 'package:ai_food_analyzer/features/capture/presentation/pages/camera_page.dart';
import 'package:ai_food_analyzer/features/capture/presentation/pages/photo_preview_page.dart';
import 'package:ai_food_analyzer/features/home/presentation/pages/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.camera,
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: AppRoutes.preview,
        builder: (context, state) {
          final imagePath = state.extra;

          if (imagePath is! String || imagePath.isEmpty) {
            return const HomePage();
          }

          return PhotoPreviewPage(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final arguments = state.extra;

          if (arguments is! FoodAnalysisResultArguments) {
            return const HomePage();
          }

          return FoodAnalysisResultPage(arguments: arguments);
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

abstract final class AppRoutes {
  static const home = '/';
  static const camera = '/camera';
  static const preview = '/preview';
  static const result = '/result';
}
