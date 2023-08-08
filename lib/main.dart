import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vietmap_map/features/navigation_screen/navigation_screen.dart';
import 'package:vietmap_map/features/pick_address_screen/pick_address_screen.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_bloc.dart';
import 'package:vietmap_map/features/routing_screen/routing_screen.dart';
import 'package:vietmap_map/features/routing_screen/search_address.dart';
import 'package:vietmap_map/features/search_screen/search_screen.dart';

import 'constants/route.dart';
import 'core/firebase_remote_config.dart';
import 'features/map_screen/bloc/map_bloc.dart';
import 'features/map_screen/maps_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  try {
    await FirebaseRemoteConfigure.initConfig();
    await FirebaseRemoteConfigure.getAllRemoteConfigValues();
  } catch (e) {
    FirebaseAnalytics.instance
        .logEvent(name: 'error_init_firebase_remote_config');
    try {
      await FirebaseRemoteConfigure.getAllRemoteConfigValues();
    } catch (e) {
      // ignore: avoid_print
    }
  }
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => MapBloc()),
      BlocProvider(create: (context) => RoutingBloc()),
    ],
    child: MaterialApp(
      title: 'VietMap Flutter GL',
      routes: {
        Routes.searchScreen: (context) => const SearchScreen(),
        Routes.mapScreen: (context) => const MapScreen(),
        Routes.routingScreen: (context) => const RoutingScreen(),
        Routes.navigationScreen: (context) => const NavigationScreen(),
        Routes.pickAddressScreen: (context) => const PickAddressScreen(),
        Routes.searchAddressForRoutingScreen: (context) =>
            const SearchAddress(),
      },
      initialRoute: Routes.mapScreen,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
    ),
  ));
}
