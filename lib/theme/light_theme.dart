import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  disabledColor: Color(0xFFBABFC4),
  backgroundColor: Color(0xFFF3F3F3),
  errorColor: Color(0xFF20373F),
  brightness: Brightness.light,
  hintColor: Color(0xFF9F9F9F),
  cardColor: Colors.white,
  primaryColor: Color(0xff233D8C),
  secondaryHeaderColor: Color(0xFF038b43),
  colorScheme: ColorScheme.light(primary: Color(0xffF2C791), secondary: Color(0xff233D8C)),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(primary: Color(0xff20373F))),
);