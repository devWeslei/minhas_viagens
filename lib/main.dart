import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'SplashScreen.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(MaterialApp(
    title: "Minhas viagens",
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

