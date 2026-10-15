import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle monoStyle(
  double s,
  Color c, {
  FontWeight w = FontWeight.w700,
  double ls = 0,
}) => GoogleFonts.jetBrainsMono(
  fontSize: s,
  fontWeight: w,
  color: c,
  letterSpacing: ls,
);

TextStyle uiStyle(
  double s,
  Color c, {
  FontWeight w = FontWeight.w700,
  double ls = 0,
}) => GoogleFonts.inter(fontSize: s, fontWeight: w, color: c, letterSpacing: ls);

TextStyle sansStyle(
  double s,
  Color c, {
  FontWeight w = FontWeight.w400,
  double ls = 0,
}) => GoogleFonts.inter(fontSize: s, fontWeight: w, color: c, letterSpacing: ls);

TextStyle brandStyle(double s, Color c) => GoogleFonts.barlowSemiCondensed(
  fontSize: s,
  fontWeight: FontWeight.w700,
  color: c,
  height: 1,
  letterSpacing: 1,
);
