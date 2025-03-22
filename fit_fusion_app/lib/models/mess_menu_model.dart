import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MessMenu {
  final String day;
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;
  final String? pdfPath;

  MessMenu({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
    this.pdfPath,
  });

  factory MessMenu.fromJson(Map<String, dynamic> json) {
    return MessMenu(
      day: json['day'] ?? '',
      breakfast: json['breakfast'] ?? '',
      lunch: json['lunch'] ?? '',
      snacks: json['snacks'] ?? '',
      dinner: json['dinner'] ?? '',
      pdfPath: json['pdfPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'breakfast': breakfast,
      'lunch': lunch,
      'snacks': snacks,
      'dinner': dinner,
      'pdfPath': pdfPath,
    };
  }
}

class MessMenuOfTheWeek {
  final List<MessMenu> menuItems;

  MessMenuOfTheWeek({required this.menuItems});

  factory MessMenuOfTheWeek.fromJson(Map<String, dynamic> json) {
    List<MessMenu> menus = [];
    if (json['menuItems'] != null) {
      json['menuItems'].forEach((item) {
        menus.add(MessMenu.fromJson(item));
      });
    }
    return MessMenuOfTheWeek(menuItems: menus);
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItems': menuItems.map((menu) => menu.toJson()).toList(),
    };
  }

  // Get menu for a specific day
  MessMenu? getMenuForDay(String day) {
    try {
      return menuItems.firstWhere(
        (menu) => menu.day.toLowerCase() == day.toLowerCase(),
      );
    } catch (e) {
      debugPrint('No menu found for $day: $e');
      return null;
    }
  }

  // Get menu for today
  MessMenu? getTodayMenu() {
    final now = DateTime.now();
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final today = dayNames[now.weekday - 1]; // weekday is 1-7, where 1 is Monday
    return getMenuForDay(today);
  }
}
