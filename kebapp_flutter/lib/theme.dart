import 'package:flutter/material.dart';

const primary = Color(0xff674727);
const secondary = Color(0xffEA9F53);
const tertiary = Color(0xff60ADED);

final buttonBorder = RoundedRectangleBorder(
  borderRadius: BorderRadiusGeometry.circular(2),
);

final theme = ThemeData(
  primaryColor: primary,
  appBarTheme: AppBarTheme(
    color: primary,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  scaffoldBackgroundColor: Colors.grey.shade200,
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 8,
    shape: BeveledRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: buttonBorder,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: buttonBorder,
      side: BorderSide(width: 2),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.grey.shade200,
  ),
);
