import 'package:flutter/material.dart';

class AppConstants {
  static const int AAPID = 1461691479;
  static const String AAPSIGN =
      "6191c6bb0f3b30e6d3231ccbfcacf2e354808deb2a6587e6692f74615a0a2a9b";
  static const String APP_NAME = "Hello Dost";
  static const Color appcolor = Color.fromARGB(255, 29, 28, 28);
  static const Color appsecondaryColor = Color.fromARGB(255, 221, 221, 221);
  static const double voiceCallRatePerSecond = 18.0 / 60.0; // 0.3 coins/sec (6₹/min = 18 coins/min)
  static const double videoCallRatePerSecond = 60.0 / 60.0; // 1 coin/sec (20₹/min = 60 coins/min)
  static const String razorpayKey = "rzp_test_GcZZFDPP0jHtC4";
}
