import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class InitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final bool isCurrentUser;

  const InitialAvatar({
    Key? key,
    required this.name,
    required this.size,
    this.backgroundColor,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate initials from name
    final initials = _getInitials(name);
    
    // Generate a consistent color based on the name
    final color = backgroundColor ?? _getAvatarColor(name);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isCurrentUser 
            ? Border.all(color: AppTheme.accentColor, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  /// Extracts initials from a name (first letter of first name and last name)
  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      // Get first letter of first name and first letter of last name
      return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      // If only one name, use first letter
      return nameParts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Generates a consistent color based on the name
  Color _getAvatarColor(String name) {
    // Create a list of vibrant colors
    final colors = [
      Colors.red[700]!,
      Colors.pink[700]!,
      Colors.purple[700]!,
      Colors.deepPurple[700]!,
      Colors.indigo[700]!,
      Colors.blue[700]!,
      Colors.lightBlue[700]!,
      Colors.cyan[700]!,
      Colors.teal[700]!,
      Colors.green[700]!,
      Colors.lightGreen[700]!,
      Colors.lime[700]!,
      Colors.amber[700]!,
      Colors.orange[700]!,
      Colors.deepOrange[700]!,
      Colors.brown[700]!,
    ];

    // Use the sum of character codes to generate a consistent index
    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      sum += name.codeUnitAt(i);
    }
    
    // Get a consistent color from the list
    return colors[sum % colors.length];
  }
}
