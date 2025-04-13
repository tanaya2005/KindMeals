// // import 'package:flutter/material.dart';
// // import 'package:carousel_slider/carousel_slider.dart';
// // import 'package:kindmeals/screens/donation/post_donation_screen.dart';
// // import 'package:kindmeals/screens/profile/profile_screen.dart';
// // import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import '../../services/firebase_service.dart';
// // import '../../services/api_service.dart';
// // // import 'post_donation_screen.dart';
// // import 'view_donations_screen.dart';

// // class DashboardScreen extends StatefulWidget {
// //   const DashboardScreen({super.key});

// //   @override
// //   State<DashboardScreen> createState() => _DashboardScreenState();
// // }

// // class _DashboardScreenState extends State<DashboardScreen> {
// //   final _firebaseService = FirebaseService();
// //   final _apiService = ApiService();
// //   int _selectedIndex = 0;
// //   bool _isInitialized = false;
// //   String _userType = '';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchUserProfile();
// //   }

// //   Future<void> _fetchUserProfile() async {
// //     try {
// //       final directProfile = await _apiService.getDirectUserProfile();

// //       setState(() {
// //         _isInitialized = true;
// //         _userType = directProfile['userType'] ?? '';
// //       });

// //       print('User type detected: $_userType');
// //     } catch (e) {
// //       print('Error fetching user profile: $e');
// //       setState(() {
// //         _isInitialized =
// //             true; // Still mark as initialized to avoid perpetual loading
// //       });
// //     }
// //   }

// //   final List<Widget> _screens = [
// //     const _HomeScreen(),
// //     const PostDonationScreen(),
// //     const ViewDonationsScreen(),
// //     const ProfileScreen(),
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     if (!_isInitialized) {
// //       return const Scaffold(
// //         body: Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       );
// //     }

// //     return WillPopScope(
// //       onWillPop: () async {
// //         // Show logout dialog
// //         final shouldLogout = await showDialog<bool>(
// //           context: context,
// //           builder: (context) => AlertDialog(
// //             title: const Text('Logout'),
// //             content: const Text('Are you sure you want to logout?'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context, false),
// //                 child: const Text('Cancel'),
// //               ),
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context, true),
// //                 child: const Text('Logout'),
// //               ),
// //             ],
// //           ),
// //         );

// //         if (shouldLogout == true) {
// //           await _firebaseService.signOut();
// //           if (mounted) {
// //             Navigator.pushNamedAndRemoveUntil(
// //               context,
// //               '/',
// //               (route) => false,
// //             );
// //           }
// //         }
// //         return false;
// //       },
// //       child: Scaffold(
// //         body: _screens[_selectedIndex],
// //         bottomNavigationBar: BottomNavigationBar(
// //           currentIndex: _selectedIndex,
// //           onTap: (index) {
// //             setState(() {
// //               _selectedIndex = index;
// //             });
// //           },
// //           elevation: 15,
// //           selectedItemColor: Colors.green,
// //           unselectedItemColor: Colors.grey,
// //           type: BottomNavigationBarType.fixed,
// //           items: const [
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.home_rounded),
// //               label: 'Home',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.add_circle_rounded),
// //               label: 'Post Donation',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.visibility_rounded),
// //               label: 'View Donations',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.person_rounded),
// //               label: 'Profile',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _HomeScreen extends StatefulWidget {
// //   const _HomeScreen();

// //   @override
// //   State<_HomeScreen> createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<_HomeScreen> {
// //   int _currentCarouselIndex = 0;
// //   final List<Map<String, dynamic>> _carouselItems = [
// //     {
// //       'image': 'assets/images/banner1.jpg',
// //       'title': 'Share Food, Share Love',
// //       'subtitle': 'Help us fight hunger in your community',
// //     },
// //     {
// //       'image': 'assets/images/banner2.jpg',
// //       'title': 'Join 1000+ Donors',
// //       'subtitle': 'Make a difference today',
// //     },
// //     {
// //       'image': 'assets/images/banner3.jpg',
// //       'title': 'Fresh Food Donations',
// //       'subtitle': 'Reducing waste, feeding people',
// //     },
// //     {
// //       'image': 'assets/images/banner4.jpg',
// //       'title': 'Become a Volunteer',
// //       'subtitle': 'Your time can change lives',
// //     },
// //   ];

// //   final List<Map<String, dynamic>> _topVolunteers = [
// //     {
// //       'name': 'Sarah Johnson',
// //       'donations': 32,
// //       'avatar': 'assets/images/volunteer1.jpg',
// //       'badge': 'Gold',
// //     },
// //     {
// //       'name': 'Michael Chen',
// //       'donations': 28,
// //       'avatar': 'assets/images/volunteer2.jpg',
// //       'badge': 'Silver',
// //     },
// //     {
// //       'name': 'Priya Patel',
// //       'donations': 25,
// //       'avatar': 'assets/images/volunteer3.jpg',
// //       'badge': 'Bronze',
// //     },
// //   ];

// //   final List<Map<String, dynamic>> _reviews = [
// //     {
// //       'name': 'John Doe',
// //       'rating': 5,
// //       'comment':
// //           'This app made donating leftover food from our restaurant so easy! The volunteers picked up everything within 30 minutes.',
// //       'date': '2 days ago',
// //       'avatar': 'assets/images/user1.jpg',
// //     },
// //     {
// //       'name': 'Emily Roberts',
// //       'rating': 5,
// //       'comment':
// //           'As a recipient, I am so grateful for this platform. The food donations have helped my family during tough times.',
// //       'date': '1 week ago',
// //       'avatar': 'assets/images/user2.jpg',
// //     },
// //     {
// //       'name': 'Raj Sharma',
// //       'rating': 4,
// //       'comment':
// //           'Great initiative! I volunteer weekly and the app makes coordination seamless. Just wish there was a chat feature.',
// //       'date': '2 weeks ago',
// //       'avatar': 'assets/images/user3.jpg',
// //     },
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Welcome Header with Gradient
// //             _buildWelcomeHeader(),

// //             // Featured Carousel
// //             _buildCarousel(),

// //             // Main Action Buttons
// //             _buildMainActions(),

// //             // Top Volunteers Section
// //             _buildTopVolunteers(),

// //             // Reviews Section
// //             _buildReviews(),

// //             // Footer with Social Links
// //             _buildFooter(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWelcomeHeader() {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             Colors.green.shade800,
// //             Colors.green.shade600,
// //           ],
// //         ),
// //         borderRadius: const BorderRadius.only(
// //           bottomLeft: Radius.circular(30),
// //           bottomRight: Radius.circular(30),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.green.withOpacity(0.3),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Welcome to',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       color: Colors.white70,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 5),
// //                   Row(
// //                     children: [
// //                       const Text(
// //                         'KindMeals',
// //                         style: TextStyle(
// //                           fontSize: 32,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 8, vertical: 4),
// //                         decoration: BoxDecoration(
// //                           color: Colors.amber,
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         child: const Text(
// //                           'DONATE',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 12,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.all(10),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: const Icon(
// //                       Icons.notifications_none_rounded,
// //                       color: Colors.white,
// //                       size: 26,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 20),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(15),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.05),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 5),
// //                 ),
// //               ],
// //             ),
// //             child: Row(
// //               children: [
// //                 const Icon(Icons.search, color: Colors.grey),
// //                 const SizedBox(width: 12),
// //                 const Expanded(
// //                   child: Text(
// //                     'Search for donations near you...',
// //                     style: TextStyle(color: Colors.grey, fontSize: 16),
// //                   ),
// //                 ),
// //                 Container(
// //                   padding: const EdgeInsets.all(8),
// //                   decoration: BoxDecoration(
// //                     color: Colors.green.shade100,
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Icon(
// //                     Icons.tune_rounded,
// //                     color: Colors.green.shade700,
// //                     size: 20,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCarousel() {
// //     return Column(
// //       children: [
// //         const SizedBox(height: 20),
// //         CarouselSlider.builder(
// //           itemCount: _carouselItems.length,
// //           itemBuilder: (context, index, realIndex) {
// //             return Container(
// //               margin: const EdgeInsets.symmetric(horizontal: 5),
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(20),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.1),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 5),
// //                   ),
// //                 ],
// //               ),
// //               child: Stack(
// //                 children: [
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(20),
// //                     child: Image.asset(
// //                       _carouselItems[index]['image'],
// //                       width: double.infinity,
// //                       height: 200,
// //                       fit: BoxFit.cover,
// //                     ),
// //                   ),
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(20),
// //                       gradient: LinearGradient(
// //                         begin: Alignment.topCenter,
// //                         end: Alignment.bottomCenter,
// //                         colors: [
// //                           Colors.transparent,
// //                           Colors.black.withOpacity(0.7),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   Positioned(
// //                     bottom: 0,
// //                     left: 0,
// //                     right: 0,
// //                     child: Container(
// //                       padding: const EdgeInsets.all(20),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             _carouselItems[index]['title'],
// //                             style: const TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 20,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 5),
// //                           Text(
// //                             _carouselItems[index]['subtitle'],
// //                             style: TextStyle(
// //                               color: Colors.white.withOpacity(0.8),
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //           options: CarouselOptions(
// //             height: 200,
// //             viewportFraction: 0.92,
// //             enlargeCenterPage: true,
// //             autoPlay: true,
// //             autoPlayInterval: const Duration(seconds: 4),
// //             onPageChanged: (index, reason) {
// //               setState(() {
// //                 _currentCarouselIndex = index;
// //               });
// //             },
// //           ),
// //         ),
// //         const SizedBox(height: 15),
// //         AnimatedSmoothIndicator(
// //           activeIndex: _currentCarouselIndex,
// //           count: _carouselItems.length,
// //           effect: ExpandingDotsEffect(
// //             dotHeight: 8,
// //             dotWidth: 8,
// //             activeDotColor: Colors.green.shade600,
// //             dotColor: Colors.grey.shade300,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildMainActions() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: _buildActionButton(
// //               title: 'Post a Donation',
// //               icon: Icons.volunteer_activism_rounded,
// //               color: Colors.green.shade600,
// //               onTap: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                       builder: (context) => const PostDonationScreen()),
// //                 );
// //               },
// //             ),
// //           ),
// //           const SizedBox(width: 15),
// //           Expanded(
// //             child: _buildActionButton(
// //               title: 'View Donations',
// //               icon: Icons.search_rounded,
// //               color: Colors.blue.shade600,
// //               onTap: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                       builder: (context) => const ViewDonationsScreen()),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildActionButton({
// //     required String title,
// //     required IconData icon,
// //     required Color color,
// //     required VoidCallback onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(vertical: 20),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(15),
// //           boxShadow: [
// //             BoxShadow(
// //               color: color.withOpacity(0.15),
// //               blurRadius: 10,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //           border: Border.all(
// //             color: color.withOpacity(0.1),
// //             width: 1,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: color.withOpacity(0.1),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 icon,
// //                 color: color,
// //                 size: 28,
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               title,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: color,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTopVolunteers() {
// //     return Container(
// //       padding: const EdgeInsets.all(20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               const Text(
// //                 'Top Volunteers',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: () {
// //                   // Navigate to all volunteers
// //                 },
// //                 child: Row(
// //                   children: [
// //                     Text(
// //                       'All Volunteers',
// //                       style: TextStyle(
// //                         color: Colors.green.shade600,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                     Icon(
// //                       Icons.arrow_forward_ios,
// //                       size: 14,
// //                       color: Colors.green.shade600,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 15),
// //           SizedBox(
// //             height: 120,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: _topVolunteers.length,
// //               itemBuilder: (context, index) {
// //                 final volunteer = _topVolunteers[index];
// //                 return Container(
// //                   width: 150,
// //                   margin: const EdgeInsets.only(right: 15),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(15),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.05),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 5),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Stack(
// //                         alignment: Alignment.center,
// //                         children: [
// //                           CircleAvatar(
// //                             radius: 30,
// //                             backgroundImage: AssetImage(volunteer['avatar']),
// //                           ),
// //                           Positioned(
// //                             right: 0,
// //                             bottom: 0,
// //                             child: Container(
// //                               padding: const EdgeInsets.symmetric(
// //                                   horizontal: 6, vertical: 2),
// //                               decoration: BoxDecoration(
// //                                 color: _getBadgeColor(volunteer['badge']),
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                               child: Text(
// //                                 volunteer['badge'],
// //                                 style: const TextStyle(
// //                                   color: Colors.white,
// //                                   fontSize: 10,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 10),
// //                       Text(
// //                         volunteer['name'],
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 14,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       const SizedBox(height: 2),
// //                       Text(
// //                         '${volunteer['donations']} donations',
// //                         style: TextStyle(
// //                           color: Colors.grey.shade600,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Color _getBadgeColor(String badge) {
// //     switch (badge) {
// //       case 'Gold':
// //         return Colors.amber.shade700;
// //       case 'Silver':
// //         return Colors.blueGrey.shade400;
// //       case 'Bronze':
// //         return Colors.brown.shade400;
// //       default:
// //         return Colors.blue;
// //     }
// //   }

// //   Widget _buildReviews() {
// //     return Container(
// //       padding: const EdgeInsets.all(20),
// //       color: Colors.grey.shade50,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               const Text(
// //                 'Reviews & Feedback',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: () {
// //                   // Navigate to all reviews
// //                 },
// //                 child: Row(
// //                   children: [
// //                     Text(
// //                       'View All',
// //                       style: TextStyle(
// //                         color: Colors.green.shade600,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                     Icon(
// //                       Icons.arrow_forward_ios,
// //                       size: 14,
// //                       color: Colors.green.shade600,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 15),
// //           ListView.builder(
// //             physics: const NeverScrollableScrollPhysics(),
// //             shrinkWrap: true,
// //             itemCount: _reviews.length,
// //             itemBuilder: (context, index) {
// //               final review = _reviews[index];
// //               return Container(
// //                 margin: const EdgeInsets.only(bottom: 15),
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(15),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withOpacity(0.03),
// //                       blurRadius: 10,
// //                       offset: const Offset(0, 5),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         CircleAvatar(
// //                           radius: 22,
// //                           backgroundImage: AssetImage(review['avatar']),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 review['name'],
// //                                 style: const TextStyle(
// //                                   fontSize: 16,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               Text(
// //                                 review['date'],
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.grey.shade600,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         Row(
// //                           children: List.generate(
// //                             review['rating'],
// //                             (i) => const Icon(
// //                               Icons.star,
// //                               color: Colors.amber,
// //                               size: 16,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 12),
// //                     Text(
// //                       review['comment'],
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.grey.shade700,
// //                         height: 1.4,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFooter() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
// //       color: Colors.green.shade800,
// //       child: Column(
// //         children: [
// //           const Text(
// //             'KindMeals',
// //             style: TextStyle(
// //               color: Colors.white,
// //               fontSize: 24,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           const SizedBox(height: 5),
// //           Text(
// //             'Share Food, Share Love',
// //             style: TextStyle(
// //               color: Colors.white.withOpacity(0.7),
// //               fontSize: 14,
// //             ),
// //           ),
// //           const SizedBox(height: 20),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               _buildSocialIcon(Icons.facebook),
// //               _buildSocialIcon(FontAwesomeIcons.whatsapp),
// //               _buildSocialIcon(Icons.telegram),
// //               _buildSocialIcon(Icons.email_rounded),
// //               _buildSocialIcon(Icons.language_rounded),
// //             ],
// //           ),
// //           const SizedBox(height: 25),
// //           const Divider(color: Colors.white24),
// //           const SizedBox(height: 15),
// //           Text(
// //             'Privacy Policy | Terms of Service | Contact Us',
// //             style: TextStyle(
// //               color: Colors.white.withOpacity(0.6),
// //               fontSize: 12,
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //           Text(
// //             ' 2025 KindMeals. All rights reserved.',
// //             style: TextStyle(
// //               color: Colors.white.withOpacity(0.6),
// //               fontSize: 12,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSocialIcon(IconData icon) {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 8),
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.2),
// //         shape: BoxShape.circle,
// //       ),
// //       child: Icon(
// //         icon,
// //         color: Colors.white,
// //         size: 24,
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:kindmeals/screens/donation/post_donation_screen.dart';
// import 'package:kindmeals/screens/profile/profile_screen.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../../services/firebase_service.dart';
// import '../../services/api_service.dart';
// import 'view_donations_screen.dart';

// // New Leaderboard Screen
// class LeaderboardScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> volunteers;

//   const LeaderboardScreen({super.key, required this.volunteers});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leaderboard'),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: volunteers.length,
//         itemBuilder: (context, index) {
//           final volunteer = volunteers[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundImage: AssetImage(volunteer['avatar']),
//               ),
//               title: Text(
//                 volunteer['name'],
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text('${volunteer['donations']} donations delivered'),
//               trailing: index < 3
//                   ? Container(
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: _getMedalColor(index),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${index + 1}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     )
//                   : Text(
//                       '#${index + 1}',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Color _getMedalColor(int position) {
//     switch (position) {
//       case 0:
//         return Colors.amber.shade700; // Gold
//       case 1:
//         return Colors.blueGrey.shade400; // Silver
//       case 2:
//         return Colors.brown.shade400; // Bronze
//       default:
//         return Colors.blue;
//     }
//   }
// }

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   final _firebaseService = FirebaseService();
//   final _apiService = ApiService();
//   int _selectedIndex = 0;
//   bool _isInitialized = false;
//   String _userType = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserProfile();
//   }

//   Future<void> _fetchUserProfile() async {
//     try {
//       final directProfile = await _apiService.getDirectUserProfile();

//       setState(() {
//         _isInitialized = true;
//         _userType = directProfile['userType'] ?? '';
//       });

//       print('User type detected: $_userType');
//     } catch (e) {
//       print('Error fetching user profile: $e');
//       setState(() {
//         _isInitialized = true;
//       });
//     }
//   }

//   final List<Widget> _screens = [
//     const _HomeScreen(),
//     const PostDonationScreen(),
//     const ViewDonationsScreen(),
//     const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return WillPopScope(
//       onWillPop: () async {
//         final shouldLogout = await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Logout'),
//             content: const Text('Are you sure you want to logout?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Logout'),
//               ),
//             ],
//           ),
//         );

//         if (shouldLogout == true) {
//           await _firebaseService.signOut();
//           if (mounted) {
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               '/',
//               (route) => false,
//             );
//           }
//         }
//         return false;
//       },
//       child: Scaffold(
//         body: _screens[_selectedIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           elevation: 15,
//           selectedItemColor: Colors.green,
//           unselectedItemColor: Colors.grey,
//           type: BottomNavigationBarType.fixed,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_rounded),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.add_circle_rounded),
//               label: 'Post Donation',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.visibility_rounded),
//               label: 'View Donations',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_rounded),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _HomeScreen extends StatefulWidget {
//   const _HomeScreen();

//   @override
//   State<_HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<_HomeScreen> {
//   int _currentCarouselIndex = 0;
//   final List<Map<String, dynamic>> _carouselItems = [
//     {
//       'image': 'assets/images/food1.jpg',
//       'title': 'Share Food, Share Love',
//       'subtitle': 'Help us fight hunger in your community',
//       'color': Colors.green,
//     },
//     {
//       'image': 'assets/images/food2.jpg',
//       'title': 'Join 1000+ Donors',
//       'subtitle': 'Make a difference today',
//       'color': Colors.blue,
//     },
//     {
//       'image': 'assets/images/food3.jpg',
//       'title': 'Fresh Food Donations',
//       'subtitle': 'Reducing waste, feeding people',
//       'color': Colors.orange,
//     },
//     {
//       'image': 'assets/images/food4.jpg',
//       'title': 'Become a Volunteer',
//       'subtitle': 'Your time can change lives',
//       'color': Colors.purple,
//     },
//   ];

//   final List<Map<String, dynamic>> _leaderboard = [
//     {
//       'name': 'Sarah Johnson',
//       'donations': 32,
//       'avatar': 'assets/images/volunteer1.jpg',
//     },
//     {
//       'name': 'Michael Chen',
//       'donations': 28,
//       'avatar': 'assets/images/volunteer2.jpg',
//     },
//     {
//       'name': 'Priya Patel',
//       'donations': 25,
//       'avatar': 'assets/images/volunteer3.jpg',
//     },
//     {
//       'name': 'David Wilson',
//       'donations': 22,
//       'avatar': 'assets/images/volunteer4.jpg',
//     },
//     {
//       'name': 'Emma Garcia',
//       'donations': 19,
//       'avatar': 'assets/images/volunteer5.jpg',
//     },
//   ];

//   final List<Map<String, dynamic>> _reviews = [
//     {
//       'name': 'John Doe',
//       'rating': 5,
//       'comment':
//           'This app made donating leftover food from our restaurant so easy! The volunteers picked up everything within 30 minutes.',
//       'date': '2 days ago',
//       'avatar': 'assets/images/user1.jpg',
//     },
//     {
//       'name': 'Emily Roberts',
//       'rating': 5,
//       'comment':
//           'As a recipient, I am so grateful for this platform. The food donations have helped my family during tough times.',
//       'date': '1 week ago',
//       'avatar': 'assets/images/user2.jpg',
//     },
//     {
//       'name': 'Raj Sharma',
//       'rating': 4,
//       'comment':
//           'Great initiative! I volunteer weekly and the app makes coordination seamless. Just wish there was a chat feature.',
//       'date': '2 weeks ago',
//       'avatar': 'assets/images/user3.jpg',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome Header with Gradient
//             _buildWelcomeHeader(),

//             // Featured Carousel
//             _buildCarousel(),

//             // Leaderboard Section
//             _buildLeaderboard(),

//             // Reviews Section
//             _buildReviews(),

//             // Footer with Social Links
//             _buildFooter(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.green.shade800,
//             Colors.green.shade600,
//           ],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Welcome to',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white70,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Row(
//                     children: [
//                       const Text(
//                         'KindMeals',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.amber,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Text(
//                           'DONATE',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.notifications_none_rounded,
//                   color: Colors.white,
//                   size: 26,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCarousel() {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         CarouselSlider.builder(
//           itemCount: _carouselItems.length,
//           itemBuilder: (context, index, realIndex) {
//             final item = _carouselItems[index];
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 15,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(25),
//                 child: Stack(
//                   children: [
//                     Image.asset(
//                       item['image'],
//                       width: double.infinity,
//                       height: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.7),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 30,
//                       left: 20,
//                       right: 20,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item['title'],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               height: 1.2,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             item['subtitle'],
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.9),
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//           options: CarouselOptions(
//             height: MediaQuery.of(context).size.height * 0.35,
//             viewportFraction: 0.9,
//             enlargeCenterPage: true,
//             autoPlay: true,
//             autoPlayInterval: const Duration(seconds: 5),
//             autoPlayAnimationDuration: const Duration(milliseconds: 800),
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _currentCarouselIndex = index;
//               });
//             },
//           ),
//         ),
//         const SizedBox(height: 15),
//         AnimatedSmoothIndicator(
//           activeIndex: _currentCarouselIndex,
//           count: _carouselItems.length,
//           effect: ExpandingDotsEffect(
//             dotHeight: 8,
//             dotWidth: 8,
//             activeDotColor: Colors.green.shade600,
//             dotColor: Colors.grey.shade300,
//             spacing: 5,
//             expansionFactor: 3,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLeaderboard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Top Volunteers Leaderboard',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LeaderboardScreen(
//                         volunteers: _leaderboard,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Row(
//                   children: [
//                     Text(
//                       'View All',
//                       style: TextStyle(
//                         color: Colors.green.shade600,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 14,
//                       color: Colors.green.shade600,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Header row
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(15),
//                       topRight: Radius.circular(15),
//                     ),
//                   ),
//                   child: const Row(
//                     children: [
//                       SizedBox(width: 40),
//                       Expanded(
//                         child: Text(
//                           'Name',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         'Donations',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Top 3 volunteers with medals
//                 ...List.generate(3, (index) {
//                   if (index >= _leaderboard.length) return const SizedBox();
//                   final volunteer = _leaderboard[index];
//                   return Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Colors.grey.shade200,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _getMedalColor(index),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '${index + 1}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         CircleAvatar(
//                           radius: 18,
//                           backgroundImage: AssetImage(volunteer['avatar']),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             volunteer['name'],
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           volunteer['donations'].toString(),
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//                 // "View All" button at bottom
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LeaderboardScreen(
//                           volunteers: _leaderboard,
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text('View Full Leaderboard'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getMedalColor(int position) {
//     switch (position) {
//       case 0:
//         return Colors.amber.shade700; // Gold
//       case 1:
//         return Colors.blueGrey.shade400; // Silver
//       case 2:
//         return Colors.brown.shade400; // Bronze
//       default:
//         return Colors.blue;
//     }
//   }

//   Widget _buildReviews() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       color: Colors.grey.shade50,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Reviews & Feedback',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Navigate to all reviews
//                 },
//                 child: Row(
//                   children: [
//                     Text(
//                       'View All',
//                       style: TextStyle(
//                         color: Colors.green.shade600,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 14,
//                       color: Colors.green.shade600,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           ListView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             itemCount: _reviews.length,
//             itemBuilder: (context, index) {
//               final review = _reviews[index];
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 15),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.03),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 22,
//                           backgroundImage: AssetImage(review['avatar']),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 review['name'],
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 review['date'],
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Row(
//                           children: List.generate(
//                             review['rating'],
//                             (i) => const Icon(
//                               Icons.star,
//                               color: Colors.amber,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       review['comment'],
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//       color: Colors.green.shade800,
//       child: Column(
//         children: [
//           const Text(
//             'KindMeals',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             'Share Food, Share Love',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.7),
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildSocialIcon(Icons.facebook),
//               _buildSocialIcon(FontAwesomeIcons.whatsapp),
//               _buildSocialIcon(Icons.telegram),
//               _buildSocialIcon(Icons.email_rounded),
//               _buildSocialIcon(Icons.language_rounded),
//             ],
//           ),
//           const SizedBox(height: 25),
//           const Divider(color: Colors.white24),
//           const SizedBox(height: 15),
//           Text(
//             'Privacy Policy | Terms of Service | Contact Us',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.6),
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             ' 2025 KindMeals. All rights reserved.',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.6),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSocialIcon(IconData icon) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(
//         icon,
//         color: Colors.white,
//         size: 24,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kindmeals/screens/dashboard/post_donation_screen.dart';
// import 'package:kindmeals/screens/donation/post_donation_screen.dart';
import 'package:kindmeals/screens/leaderboard/donorleaderboard.dart';
import 'package:kindmeals/screens/leaderboard/volunteerleaderboard.dart';
import 'package:kindmeals/screens/profile/profile_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import 'view_donations_screen.dart';
import 'volunteers_screen.dart';

// Volunteer Leaderboard Screen
// class VolunteerLeaderboardScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> volunteers;

//   const VolunteerLeaderboardScreen({super.key, required this.volunteers});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Volunteer Leaderboard'),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: volunteers.length,
//         itemBuilder: (context, index) {
//           final volunteer = volunteers[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundImage: AssetImage(volunteer['avatar']),
//               ),
//               title: Text(
//                 volunteer['name'],
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text('${volunteer['donations']} deliveries made'),
//               trailing: index < 3
//                   ? Container(
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: _getMedalColor(index),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${index + 1}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     )
//                   : Text(
//                       '#${index + 1}',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Color _getMedalColor(int position) {
//     switch (position) {
//       case 0:
//         return Colors.amber.shade700; // Gold
//       case 1:
//         return Colors.blueGrey.shade400; // Silver
//       case 2:
//         return Colors.brown.shade400; // Bronze
//       default:
//         return Colors.blue;
//     }
//   }
// }

// Donor Leaderboard Screen
// class DonorLeaderboardScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> donors;

//   const DonorLeaderboardScreen({super.key, required this.donors});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Donor Leaderboard'),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: donors.length,
//         itemBuilder: (context, index) {
//           final donor = donors[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundImage: AssetImage(donor['avatar']),
//               ),
//               title: Text(
//                 donor['name'],
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text('${donor['meals']} meals donated'),
//               trailing: index < 3
//                   ? Container(
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: _getMedalColor(index),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${index + 1}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     )
//                   : Text(
//                       '#${index + 1}',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Color _getMedalColor(int position) {
//     switch (position) {
//       case 0:
//         return Colors.amber.shade700; // Gold
//       case 1:
//         return Colors.blueGrey.shade400; // Silver
//       case 2:
//         return Colors.brown.shade400; // Bronze
//       default:
//         return Colors.blue;
//     }
//   }
// }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  int _selectedIndex = 0;
  bool _isInitialized = false;
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final directProfile = await _apiService.getDirectUserProfile();

      setState(() {
        _isInitialized = true;
        _userType = directProfile['userType'] ?? '';
      });

      print('User type detected: $_userType');
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  final List<Widget> _screens = [
    const _HomeScreen(),
    const PostDonationScreen(),
    const ViewDonationsScreen(),
    const VolunteersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          await _firebaseService.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          }
        }
        return false;
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          elevation: 15,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded),
              label: 'Post Donation',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.visibility_rounded),
              label: 'View Donations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism_rounded),
              label: 'Volunteers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _currentCarouselIndex = 0;
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': 'assets/images/food1.jpg',
      'title': 'Share Food, Share Love',
      'subtitle': 'Help us fight hunger in your community',
      'color': Colors.green,
    },
    {
      'image': 'assets/images/food2.jpg',
      'title': 'Join 1000+ Donors',
      'subtitle': 'Make a difference today',
      'color': Colors.blue,
    },
    {
      'image': 'assets/images/food3.jpg',
      'title': 'Fresh Food Donations',
      'subtitle': 'Reducing waste, feeding people',
      'color': Colors.orange,
    },
    {
      'image': 'assets/images/food4.jpg',
      'title': 'Become a Volunteer',
      'subtitle': 'Your time can change lives',
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _volunteerLeaderboard = [
    {
      'name': 'Sarah Johnson',
      'donations': 32,
      'avatar': 'assets/images/volunteer1.jpg',
    },
    {
      'name': 'Michael Chen',
      'donations': 28,
      'avatar': 'assets/images/volunteer2.jpg',
    },
    {
      'name': 'Priya Patel',
      'donations': 25,
      'avatar': 'assets/images/volunteer3.jpg',
    },
    {
      'name': 'David Wilson',
      'donations': 22,
      'avatar': 'assets/images/volunteer4.jpg',
    },
    {
      'name': 'Emma Garcia',
      'donations': 19,
      'avatar': 'assets/images/volunteer5.jpg',
    },
  ];

  final List<Map<String, dynamic>> _donorLeaderboard = [
    {
      'name': 'Restaurant A',
      'meals': 145,
      'avatar': 'assets/images/restaurant1.jpg',
    },
    {
      'name': 'Cafe B',
      'meals': 128,
      'avatar': 'assets/images/restaurant2.jpg',
    },
    {
      'name': 'Hotel C',
      'meals': 112,
      'avatar': 'assets/images/restaurant3.jpg',
    },
    {
      'name': 'Bakery D',
      'meals': 98,
      'avatar': 'assets/images/restaurant4.jpg',
    },
    {
      'name': 'Catering E',
      'meals': 87,
      'avatar': 'assets/images/restaurant5.jpg',
    },
  ];

  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'John Doe',
      'rating': 5,
      'comment':
          'This app made donating leftover food from our restaurant so easy! The volunteers picked up everything within 30 minutes.',
      'date': '2 days ago',
      'avatar': 'assets/images/user1.jpg',
    },
    {
      'name': 'Emily Roberts',
      'rating': 5,
      'comment':
          'As a recipient, I am so grateful for this platform. The food donations have helped my family during tough times.',
      'date': '1 week ago',
      'avatar': 'assets/images/user2.jpg',
    },
    {
      'name': 'Raj Sharma',
      'rating': 4,
      'comment':
          'Great initiative! I volunteer weekly and the app makes coordination seamless. Just wish there was a chat feature.',
      'date': '2 weeks ago',
      'avatar': 'assets/images/user3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header with Gradient
            _buildWelcomeHeader(),

            // Featured Carousel
            _buildCarousel(),

            // Volunteer Leaderboard Section
            _buildVolunteerLeaderboard(),

            // Donor Leaderboard Section
            _buildDonorLeaderboard(),

            // Reviews Section
            _buildReviews(),

            // Footer with Social Links
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        'KindMeals',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'DONATE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        const SizedBox(height: 20),
        CarouselSlider.builder(
          itemCount: _carouselItems.length,
          itemBuilder: (context, index, realIndex) {
            final item = _carouselItems[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  children: [
                    Image.asset(
                      item['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['subtitle'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.35,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 15),
        AnimatedSmoothIndicator(
          activeIndex: _currentCarouselIndex,
          count: _carouselItems.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Colors.green.shade600,
            dotColor: Colors.grey.shade300,
            spacing: 5,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildVolunteerLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Volunteers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VolunteerLeaderboardScreen(
                        volunteers: _volunteerLeaderboard,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Deliveries',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Top 3 volunteers with medals
                ...List.generate(3, (index) {
                  if (index >= _volunteerLeaderboard.length)
                    return const SizedBox();
                  final volunteer = _volunteerLeaderboard[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getMedalColor(index),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(volunteer['avatar']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            volunteer['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          volunteer['donations'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // "View All" button at bottom
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VolunteerLeaderboardScreen(
                          volunteers: _volunteerLeaderboard,
                        ),
                      ),
                    );
                  },
                  child: const Text('View Full Leaderboard'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Donors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonorLeaderboardScreen(
                        donors: _donorLeaderboard,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Meals',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Top 3 donors with medals
                ...List.generate(3, (index) {
                  if (index >= _donorLeaderboard.length)
                    return const SizedBox();
                  final donor = _donorLeaderboard[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getMedalColor(index),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(donor['avatar']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            donor['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          donor['meals'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // "View All" button at bottom
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonorLeaderboardScreen(
                          donors: _donorLeaderboard,
                        ),
                      ),
                    );
                  },
                  child: const Text('View Full Leaderboard'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int position) {
    switch (position) {
      case 0:
        return Colors.amber.shade700; // Gold
      case 1:
        return Colors.blueGrey.shade400; // Silver
      case 2:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.blue;
    }
  }

  Widget _buildReviews() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews & Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all reviews
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(review['avatar']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                review['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            review['rating'],
                            (i) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review['comment'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: Colors.green.shade800,
      child: Column(
        children: [
          const Text(
            'KindMeals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Share Food, Share Love',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              _buildSocialIcon(FontAwesomeIcons.whatsapp),
              _buildSocialIcon(Icons.telegram),
              _buildSocialIcon(Icons.email_rounded),
              _buildSocialIcon(Icons.language_rounded),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          Text(
            'Privacy Policy | Terms of Service | Contact Us',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ' 2025 KindMeals. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
