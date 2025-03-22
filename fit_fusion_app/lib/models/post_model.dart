import 'package:flutter/material.dart';

class Post {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final List<Comment> comments;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    List<Comment>? comments,
    List<String>? likedBy,
  }) : 
    comments = comments ?? [],
    likedBy = likedBy ?? [];

  Post copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    String? content,
    String? imageUrl,
    DateTime? timestamp,
    List<Comment>? comments,
    List<String>? likedBy,
  }) {
    return Post(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}

class Comment {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
  });
}
