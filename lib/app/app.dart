import 'dart:async';

import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/core/localization/locale_providers.dart';
import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_theme.dart';
import 'package:ai_food_analyzer/features/premium/presentation/providers/premium_purchase_provider.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class App extends ConsumerStatefulWidget {
  const App({this.showOnboarding = false, super.key});

  final bool showOnboarding;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (AppConfig.isSupabaseConfigured) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((authState) {
            if (authState.event != AuthChangeEvent.passwordRecovery &&
                authState.event != AuthChangeEvent.signedIn) {
              return;
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (authState.event == AuthChangeEvent.signedIn) {
                  ref.read(premiumPurchaseProvider.notifier).refreshStatus();
                }
                ref
                    .read(appRouterProvider)
                    .go(
                      authState.event == AuthChangeEvent.passwordRecovery
                          ? AppRoutes.resetPassword
                          : AppRoutes.home,
                    );
              }
            });
          });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && AppConfig.isSupabaseConfigured) {
      ref.read(premiumPurchaseProvider.notifier).refreshStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    if (AppConfig.isSupabaseConfigured) ref.watch(premiumPurchaseProvider);
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final fallbackLocale = deviceLocale.languageCode == 'tr'
        ? const Locale('tr')
        : const Locale('en');
    final locale = ref.watch(appLocaleProvider).value ?? fallbackLocale;

    if (widget.showOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            router.routeInformationProvider.value.uri.path ==
                AppRoutes.splash) {
          router.go(AppRoutes.onboarding);
        }
      });
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
