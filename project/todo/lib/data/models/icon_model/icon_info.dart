import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconInfo {
  final String name;
  final IconData iconData;
  final String type;

  IconInfo({required this.name, required this.iconData, required this.type});
}

final List<List<IconInfo>> profileIconList = [
  [
    IconInfo(
        name: 'person_alt',
        iconData: CupertinoIcons.person_alt,
        type: 'profile'),
    IconInfo(
        name: 'bolt_fill', iconData: CupertinoIcons.bolt_fill, type: 'profile'),
    IconInfo(
        name: 'heart_fill',
        iconData: CupertinoIcons.heart_fill,
        type: 'profile'),
    IconInfo(
        name: 'star_fill', iconData: CupertinoIcons.star_fill, type: 'profile'),
    IconInfo(
        name: 'music_note',
        iconData: CupertinoIcons.music_note,
        type: 'profile')
  ],
  [
    IconInfo(name: 'ac_unit', iconData: Icons.ac_unit, type: 'profile'),
    IconInfo(
        name: 'sun_max_fill',
        iconData: CupertinoIcons.sun_max_fill,
        type: 'profile'),
    IconInfo(
        name: 'moon_fill', iconData: CupertinoIcons.moon_fill, type: 'profile'),
    IconInfo(
        name: 'wb_cloudy_rounded',
        iconData: Icons.wb_cloudy_rounded,
        type: 'profile'),
    IconInfo(name: 'terrain', iconData: Icons.terrain, type: 'profile')
  ],
  [
    IconInfo(
        name: 'flame_fill',
        iconData: CupertinoIcons.flame_fill,
        type: 'profile'),
    IconInfo(
        name: 'smiley_fill',
        iconData: CupertinoIcons.smiley_fill,
        type: 'profile'),
    IconInfo(name: 'outlet', iconData: Icons.outlet, type: 'profile'),
    IconInfo(name: 'cake', iconData: Icons.cake, type: 'profile'),
    IconInfo(name: 'eco', iconData: Icons.eco, type: 'profile')
  ],
  [
    IconInfo(
        name: 'palette_rounded',
        iconData: Icons.palette_rounded,
        type: 'profile'),
    IconInfo(
        name: 'ramen_dining_rounded',
        iconData: Icons.ramen_dining_rounded,
        type: 'profile'),
    IconInfo(
        name: 'sailing_sharp', iconData: Icons.sailing_sharp, type: 'profile'),
    IconInfo(name: 'school', iconData: Icons.school, type: 'profile'),
    IconInfo(name: 'waving_hand', iconData: Icons.waving_hand, type: 'profile')
  ]
];
