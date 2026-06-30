import 'package:flutter/material.dart';

enum SpecialDays { christmas, mothersDay, cyberWow }

String getFileImage(SpecialDays specialDays) {
  switch (specialDays) {
    case SpecialDays.christmas:
      return "lib/assets/christmas.png";
    case SpecialDays.mothersDay:
      return "lib/assets/banner_mothers_day.png";
    case SpecialDays.cyberWow:
      return "lib/assets/banner_cyber_wow.png";
  }
}

Widget getFlyerImage(SpecialDays specialDays) {
  switch (specialDays) {
    case SpecialDays.christmas:
      return const SizedBox(height: 70);
    case SpecialDays.mothersDay:
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Image.asset("lib/assets/mother_day_flyer.png", height: 340),
      );
    case SpecialDays.cyberWow:
      return const SizedBox(height: 40);
  }
}

