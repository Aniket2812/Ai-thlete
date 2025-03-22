import 'package:flutter/material.dart';
import '../models/post_model.dart';

class CommunityService extends ChangeNotifier {
  final List<Post> _posts = [];
  final String _currentUserAvatar = 'https://randomuser.me/api/portraits/men/32.jpg';

  CommunityService() {
    _addSamplePosts();
  }

  List<Post> get posts => _posts;

  void _addSamplePosts() {
    // Sample post 1 - New equipment in campus gym
    _posts.add(Post(
      id: '1',
      userName: 'Arjun Kumar',
      userAvatar: 'https://randomuser.me/api/portraits/men/41.jpg',
      content: '🏋️‍♂️ They finally added two new squat racks in the campus gym! No more waiting 30 minutes for leg day. The gym is getting crowded after 6pm though, so morning sessions are the move. Pro tip: The gym empties out during first year orientation week! #CampusGym #NewEquipment',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likedBy: ['user2', 'user3', 'user4'],
      comments: [
        Comment(
          id: '1',
          userName: 'Priya Singh',
          userAvatar: 'https://randomuser.me/api/portraits/women/67.jpg',
          content: 'Finally! Been waiting for this upgrade forever. How busy is it around 8am?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
        Comment(
          id: '2',
          userName: 'Rahul Verma',
          userAvatar: 'https://randomuser.me/api/portraits/men/67.jpg',
          content: 'Awesome! Does this mean they\'ll fix that broken treadmill too?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        ),
      ],
    ));

    // Sample post 2 - Dorm room workouts when gym is closed
    _posts.add(Post(
      id: '2',
      userName: 'Meera Patel',
      userAvatar: 'https://randomuser.me/api/portraits/women/33.jpg',
      content: 'Campus gym closed for maintenance during exam week 😤 So here\'s my dorm room workout: 3 sets of textbook squats, water bottle shoulder press, and bed frame dips. Anyone have other dorm workout ideas? Trying to stay on track with my fitness goals! #DormWorkout #GymClosed',
      imageUrl: 'https://images.unsplash.com/photo-1576678927484-cc907957088c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      likedBy: ['user1', 'user5'],
      comments: [
        Comment(
          id: '3',
          userName: 'Vikram Desai',
          userAvatar: 'https://randomuser.me/api/portraits/men/78.jpg',
          content: 'Try the stairwell for cardio! I run up and down all 8 floors when the gym\'s closed.',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        ),
      ],
    ));

    // Sample post 3 - Gym trainer on campus
    _posts.add(Post(
      id: '3',
      userName: 'Ananya Sharma',
      userAvatar: 'https://randomuser.me/api/portraits/women/12.jpg',
      content: 'The new campus gym trainer is actually helpful! Got a free form check on my deadlifts today and fixed the back pain I\'ve had for weeks. FYI - trainer hours are 4-7pm on weekdays. Sign up sheet fills fast! #FormMatters #CampusGymTips',
      imageUrl: 'https://images.unsplash.com/photo-1546483875-ad9014c88eba?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      likedBy: ['user1', 'user2', 'user7', 'user8'],
      comments: [],
    ));

    // Sample post 4 - Late night gym sessions
    _posts.add(Post(
      id: '4',
      userName: 'Karan Malhotra',
      userAvatar: 'https://randomuser.me/api/portraits/men/22.jpg',
      content: 'Anyone else use the campus gym at 11pm? It\'s empty and peaceful! Just discovered they extended hours till midnight during exam weeks. Tonight\'s shoulder workout was amazing with no wait times for equipment. Also, they added better lighting in the free weights area! #NightOwlLifts #EmptyGym',
      imageUrl: 'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 7)),
      likedBy: ['user3', 'user5', 'user6'],
      comments: [
        Comment(
          id: '5',
          userName: 'Aisha Khan',
          userAvatar: 'https://randomuser.me/api/portraits/women/45.jpg',
          content: 'Do they still play that awful gym playlist at night?',
          timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        ),
        Comment(
          id: '6',
          userName: 'Rohan Joshi',
          userAvatar: 'https://randomuser.me/api/portraits/men/45.jpg',
          content: 'Late night crew! I\'ll be there at 11:30 if anyone wants a spot.',
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 23)),
        ),
      ],
    ));

    // Sample post 5 - Gym membership perks
    _posts.add(Post(
      id: '5',
      userName: 'Riya Patel',
      userAvatar: 'https://randomuser.me/api/portraits/women/22.jpg',
      content: 'PSA: Your student ID gets you free protein shakes after workouts at the campus gym cafe on Tuesdays! Just show your completed workout on the FitFusion app. Also, the gym towel service is free if you signed up for the premium campus gym membership (₹1200/semester). #GymPerks #FreeStuff',
      imageUrl: 'https://images.unsplash.com/photo-1506784365847-bbad939e9335?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
      likedBy: ['user2', 'user7', 'user8', 'user9'],
      comments: [
        Comment(
          id: '7',
          userName: 'Siddharth Nair',
          userAvatar: 'https://randomuser.me/api/portraits/men/11.jpg',
          content: 'Wait, there\'s a premium membership? Where do I sign up?',
          timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
        ),
      ],
    ));
  }

  void addPost(String content, String? imageUrl) {
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: "You", // In a real app, get from user profile
      userAvatar: _currentUserAvatar,
      content: content,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );
    _posts.insert(0, newPost);
    notifyListeners();
  }

  void likePost(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      
      // Toggle like (in a real app, use current user ID instead of 'currentUser')
      if (post.likedBy.contains('currentUser')) {
        post.likedBy.remove('currentUser');
      } else {
        post.likedBy.add('currentUser');
      }
      notifyListeners();
    }
  }

  bool isPostLikedByCurrentUser(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      return _posts[postIndex].likedBy.contains('currentUser');
    }
    return false;
  }

  void addComment(String postId, String content) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: "You", // In a real app, get from user profile
        userAvatar: _currentUserAvatar,
        content: content,
        timestamp: DateTime.now(),
      );
      post.comments.add(newComment);
      notifyListeners();
    }
  }
}
