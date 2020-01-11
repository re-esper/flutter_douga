import 'package:flutter/material.dart';

class AppColor {
  static Color primary = Color(0xFF5C5C5C);
  static Color secondary = Color(0xFF51DEC6);
  static Color red = Color(0xFFFF2B45);
  static Color orange = Color(0xFFF67264);
  static Color paper = Color(0xFFF5F5F5);
  static Color lightGrey = Color(0xFFDDDDDD);
  static Color darkGrey = Color(0xFF333333);
  static Color grey = Color(0xFF888888);
  static Color blue = Color(0xFF3688FF);
  static Color golden = Color(0xff8B7961);
}

const DEFAULT_THEME_COLOR = 0xFF35374C;
const BANGUMI_REFRESH_INTERVAL = 1 * 60 * 60 * 1000; // 10 minutes

// home page
const HEADLINE_ANIME_COUNT = 4;
const HOT_ANIME_COUNT = 6;
const RECENT_ANIME_COUNT = 9;

// profile page
const PROFILE_PAGE_MAX_PREVIEWS = 8;
const HISTORY_PAGE_ITEM_PER_PAGE = 10;

// keys
const KEY_FAVOR = 'favoriteAnimes';
const KEY_HISTORY = 'historyAnimes';
const KEY_ACTORS = 'browsedActors';