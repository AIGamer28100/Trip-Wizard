import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'utils/logger.dart';
import 'screens/auth_wrapper.dart';
import 'services/auth_service.dart';
import 'repositories/trip_repository.dart';
import 'repositories/community_repository.dart';
import 'repositories/badge_repository.dart';
import 'services/connectivity_service.dart';
import 'services/cache_service.dart';
import 'services/sync_service.dart';
import 'models/trip_adapter.dart';
import 'models/itinerary_item_adapter.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging early so modules can use the logger right away.
  initLogging();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TripAdapter());
  Hive.registerAdapter(ItineraryItemAdapter());

  // Initialize services
  final cacheService = CacheService();
  await cacheService.init();

  final connectivityService = ConnectivityService();
  final syncService = SyncService(cacheService, connectivityService);

  runApp(
    TripWizardsApp(
      cacheService: cacheService,
      connectivityService: connectivityService,
      syncService: syncService,
    ),
  );
}

class TripWizardsApp extends StatelessWidget {
  final CacheService cacheService;
  final ConnectivityService connectivityService;
  final SyncService syncService;

  const TripWizardsApp({
    super.key,
    required this.cacheService,
    required this.connectivityService,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<BadgeRepository>(create: (_) => BadgeRepository()),
        Provider<CommunityRepository>(
          create: (context) => CommunityRepository(
            authService: Provider.of<AuthService>(context, listen: false),
            badgeRepository: Provider.of<BadgeRepository>(
              context,
              listen: false,
            ),
          ),
        ),
        Provider<TripRepository>(
          create: (context) => TripRepository(
            communityRepository: Provider.of<CommunityRepository>(
              context,
              listen: false,
            ),
          ),
        ),
        Provider<CacheService>(create: (_) => cacheService),
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => connectivityService,
        ),
        Provider<SyncService>(create: (_) => syncService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              // Use system colors if available, otherwise use deep purple
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;

              if (lightDynamic != null && darkDynamic != null) {
                // System colors are available
                lightColorScheme = lightDynamic.harmonized();
                darkColorScheme = darkDynamic.harmonized();
              } else {
                // Fallback to deep purple
                lightColorScheme = ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                );
                darkColorScheme = ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                );
              }

              return MaterialApp(
                title: 'Trip Wizards',
                localizationsDelegates: [AppLocalizations.delegate],
                supportedLocales: const [Locale('en')],
                theme: ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                  cardTheme: const CardThemeData(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                darkTheme: ThemeData(
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                  cardTheme: const CardThemeData(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                themeMode: themeProvider.themeMode,
                home: const AuthWrapper(),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
