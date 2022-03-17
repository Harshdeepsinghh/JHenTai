import 'dart:ui';

import 'package:flutter/material.dart';

class ColorConsts {
  static const Map<String, Color> galleryCategoryColor = {
    'Doujinshi': Color(0xfffc4e4e),
    'Manga': Color(0xfffcb417),
    'Image Set': Color(0xff5050d7),
    'Game CG': Color(0xff05bf0b),
    'Artist CG': Color(0xffdde500),
    'Cosplay': Color(0xff9755f5),
    'Non-H': Color(0xff68c9de),
    'Asian Porn': Color(0xfffe93ff),
    'Western': Color(0xff14e723),
    'Misc': Color(0xff9e9e9e),
    'other': Colors.white,
  };

  /// color for category tag
  static const Map<String, Color> tagCategoryColor = {
    'language': Color(0xfff5dff5),
    'artist': Color(0xffccd9cd),
    'character': Color(0xffc8c8e7),
    'female': Color(0xffdbceee),
    'male': Color(0xfffdd7d7),
    'parody': Color(0xffeed4c5),
    'group': Color(0xffdfd6f7),
    'cosplayer': Color(0xfff6dce9),
    'other': Color(0xfffadcdb),
  };

  /// raw tag color to tag index
  static const Map<String, int> favoriteTagIndex = <String, int>{
    '000': 0,
    'f00': 1,
    'fa0': 2,
    'dd0': 3,
    '080': 4,
    '9f4': 5,
    '4bf': 6,
    '00f': 7,
    '508': 8,
    'e8e': 9,
  };

  /// customized color for favorite tag
  static const List<Color> favoriteTagColor = <Color>[
    Color(0xff9e9e9e),
    Color(0xfffc4e4e),
    Color(0xfffcb417),
    Color(0xffdde500),
    Color(0xff17b91b),
    Color(0xff36b940),
    Color(0xff68c9de),
    Color(0xff5050d7),
    Color(0xff9755f5),
    Color(0xfffe93ff),
  ];
}