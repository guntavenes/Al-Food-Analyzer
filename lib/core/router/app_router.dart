import 'package:ai_food_analyzer/features/analysis/presentation/pages/food_analysis_result_page.dart';
import 'package:ai_food_analyzer/features/capture/presentation/pages/camera_page.dart';
import 'package:ai_food_analyzer/features/capture/presentation/pages/photo_preview_page.dart';
import 'package:ai_food_analyzer/features/history/presentation/pages/history_page.dart';
import 'package:ai_food_analyzer/features/history/presentation/pages/saved_analysis_detail_page.dart';
import 'package:ai_food_analyzer/features/home/presentation/pages/home_page.dart';
import 'package:ai_food_analyzer/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _premiumPage(
          state: state,
          child: const SplashPage(),
          transition: _AppTransition.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _premiumPage(
          state: state,
          child: const HomePage(),
          transition: _AppTransition.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.camera,
        pageBuilder: (context, state) => _premiumPage(
          state: state,
          child: const CameraPage(),
          transition: _AppTransition.scale,
        ),
      ),
      GoRoute(
        path: AppRoutes.preview,
        pageBuilder: (context, state) {
          final imagePath = state.extra;

          if (imagePath is! String || imagePath.isEmpty) {
            return _premiumPage(state: state, child: const HomePage());
          }

          return _premiumPage(
            state: state,
            child: PhotoPreviewPage(imagePath: imagePath),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.result,
        pageBuilder: (context, state) {
          final arguments = state.extra;

          if (arguments is! FoodAnalysisResultArguments) {
            return _premiumPage(state: state, child: const HomePage());
          }

          return _premiumPage(
            state: state,
            child: FoodAnalysisResultPage(arguments: arguments),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (context, state) =>
            _premiumPage(state: state, child: const HistoryPage()),
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return _premiumPage(state: state, child: const HistoryPage());
              }
              return _premiumPage(
                state: state,
                child: SavedAnalysisDetailPage(analysisId: id),
              );
            },
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const camera = '/camera';
  static const preview = '/preview';
  static const result = '/result';
  static const history = '/history';

  static String historyDetail(int id) => '$history/$id';
}

enum _AppTransition { slide, fade, scale }

CustomTransitionPage<void> _premiumPage({
  required GoRouterState state,
  required Widget child,
  _AppTransition transition = _AppTransition.slide,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final fade = FadeTransition(opacity: curved, child: child);
      return switch (transition) {
        _AppTransition.fade => fade,
        _AppTransition.scale => ScaleTransition(
          scale: Tween<double>(begin: 0.965, end: 1).animate(curved),
          child: fade,
        ),
        _AppTransition.slide => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.045, 0.018),
            end: Offset.zero,
          ).animate(curved),
          child: fade,
        ),
      };
    },
  );
}
