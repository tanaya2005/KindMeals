// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../../services/firebase_service.dart';
// import '../../services/api_service.dart';

// class VolunteerDashboardScreen extends StatefulWidget {
//   const VolunteerDashboardScreen({super.key});

//   @override
//   State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
// }

// class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
//   final _firebaseService = FirebaseService();
//   final _apiService = ApiService();
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _nearbyDonations = [];
//   List<Map<String, dynamic>> _pastDonations = [];
//   Map<String, dynamic> _volunteerProfile = {};
//   int _selectedRadius = 5; // Default radius in km
//   bool _hasNotifications = true;
//   int _currentIndex = 0; // Current tab index

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     // Simulate loading data from API
//     await Future.delayed(const Duration(seconds: 1));
    
//     // This would be replaced with actual API calls
//     setState(() {
//       _volunteerProfile = {
//         'name': 'John Smith',
//         'avatar': 'assets/images/volunteer1.jpg',
//         'deliveries': 27,
//         'rating': 4.8,
//         'status': 'Available',
//         'email': 'john.smith@example.com',
//         'phone': '+1 (555) 123-4567',
//         'address': '123 Volunteer Street, Cityville, State 12345',
//         'joinDate': 'March 15, 2024',
//         'volunteerID': 'VOL-12345',
//         'bio': 'Passionate about reducing food waste and helping those in need. I have been volunteering with food rescue organizations for over 2 years.'
//       };
      
//       _nearbyDonations = [
//         {
//           'id': '1',
//           'donor': 'Restaurant A',
//           'donorAvatar': 'assets/images/restaurant1.jpg',
//           'foodType': 'Mixed Indian Food',
//           'quantity': '5 meals',
//           'expiryTime': '3 hours',
//           'distance': '1.2 km',
//           'address': '123 Green St, Downtown',
//           'rating': 4.7,
//           'timestamp': '15 minutes ago',
//         },
//         {
//           'id': '2',
//           'donor': 'Hotel C',
//           'donorAvatar': 'assets/images/restaurant3.jpg',
//           'foodType': 'Continental Breakfast',
//           'quantity': '8 meals',
//           'expiryTime': '2 hours',
//           'distance': '2.8 km',
//           'address': '456 Park Ave, Midtown',
//           'rating': 4.5,
//           'timestamp': '32 minutes ago',
//         },
//         {
//           'id': '3',
//           'donor': 'Bakery D',
//           'donorAvatar': 'assets/images/restaurant4.jpg',
//           'foodType': 'Bread and Pastries',
//           'quantity': '12 items',
//           'expiryTime': '6 hours',
//           'distance': '3.2 km',
//           'address': '789 Baker St, Uptown',
//           'rating': 4.9,
//           'timestamp': '45 minutes ago',
//         },
//         {
//           'id': '4',
//           'donor': 'Cafe B',
//           'donorAvatar': 'assets/images/restaurant2.jpg',
//           'foodType': 'Sandwiches and Coffee',
//           'quantity': '10 servings',
//           'expiryTime': '4 hours',
//           'distance': '4.5 km',
//           'address': '101 Main St, Westside',
//           'rating': 4.3,
//           'timestamp': '1 hour ago',
//         },
//         {
//           'id': '5',
//           'donor': 'Catering E',
//           'donorAvatar': 'assets/images/restaurant5.jpg',
//           'foodType': 'Catered Event Leftovers',
//           'quantity': '20 meals',
//           'expiryTime': '5 hours',
//           'distance': '4.9 km',
//           'address': '202 Conference Center, Business District',
//           'rating': 4.6,
//           'timestamp': '1.5 hours ago',
//         },
//       ];
      
//       // Load past donations for history tab
//       _pastDonations = [
//         {
//           'id': '101',
//           'donor': 'Italian Restaurant',
//           'donorAvatar': 'assets/images/restaurant2.jpg',
//           'foodType': 'Pizza and Pasta',
//           'quantity': '8 meals',
//           'date': 'Apr 10, 2025',
//           'status': 'Delivered',
//           'recipient': 'Downtown Shelter',
//           'recipientAddress': '789 Hope St, Downtown',
//         },
//         {
//           'id': '102',
//           'donor': 'Grocery Store B',
//           'donorAvatar': 'assets/images/restaurant3.jpg',
//           'foodType': 'Fresh Produce and Dairy',
//           'quantity': '15 items',
//           'date': 'Apr 8, 2025',
//           'status': 'Delivered',
//           'recipient': 'Community Center',
//           'recipientAddress': '456 Main St, Eastside',
//         },
//         {
//           'id': '103',
//           'donor': 'Bakery A',
//           'donorAvatar': 'assets/images/restaurant4.jpg',
//           'foodType': 'Bread and Pastries',
//           'quantity': '25 items',
//           'date': 'Apr 5, 2025',
//           'status': 'Delivered',
//           'recipient': 'Family Shelter',
//           'recipientAddress': '101 Care Lane, Northside',
//         },
//         {
//           'id': '104',
//           'donor': 'Catering Service',
//           'donorAvatar': 'assets/images/restaurant5.jpg',
//           'foodType': 'Mixed Buffet Items',
//           'quantity': '30 servings',
//           'date': 'Apr 2, 2025',
//           'status': 'Delivered',
//           'recipient': 'Youth Center',
//           'recipientAddress': '222 Youth Way, Westside',
//         },
//         {
//           'id': '105',
//           'donor': 'Hotel Breakfast',
//           'donorAvatar': 'assets/images/restaurant1.jpg',
//           'foodType': 'Continental Breakfast',
//           'quantity': '12 servings',
//           'date': 'Mar 29, 2025',
//           'status': 'Delivered',
//           'recipient': 'Women\'s Shelter',
//           'recipientAddress': '555 Safe Haven, Midtown',
//         },
//       ];
      
//       _isLoading = false;
//     });
//   }

//   Future<void> _acceptDonation(String donationId) async {
//     setState(() {
//       _isLoading = true;
//     });
    
//     // Simulate API call to accept donation
//     await Future.delayed(const Duration(milliseconds: 800));
    
//     // Get the donation being accepted
//     final acceptedDonation = _nearbyDonations.firstWhere((donation) => donation['id'] == donationId);
    
//     // Add to past donations with some additional fields
//     final newPastDonation = {
//       ...acceptedDonation,
//       'date': 'Apr 13, 2025', // Today's date
//       'status': 'In Progress',
//       'recipient': 'To be determined',
//       'recipientAddress': 'To be assigned',
//     };
    
//     setState(() {
//       _pastDonations.insert(0, newPastDonation); // Add to beginning of history
//       _nearbyDonations.removeWhere((donation) => donation['id'] == donationId);
//       _isLoading = false;
//     });
    
//     // Show success message
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Donation accepted successfully! Please proceed for pickup.'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   void _filterByRadius(int radius) {
//     setState(() {
//       _selectedRadius = radius;
//       _isLoading = true;
//     });
    
//     // Simulate loading new data
//     Future.delayed(const Duration(seconds: 1), () {
//       setState(() {
//         // Filter donations based on radius
//         // In a real app, this would be a server call
//         _nearbyDonations = _nearbyDonations
//             .where((donation) => double.parse(donation['distance'].split(' ')[0]) <= radius)
//             .toList();
//         _isLoading = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildCurrentView(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         selectedItemColor: Colors.green.shade700,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history_outlined),
//             activeIcon: Icon(Icons.history),
//             label: 'History',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       floatingActionButton: _currentIndex == 0 
//         ? FloatingActionButton(
//             onPressed: () {
//               // Refresh available donations
//               setState(() {
//                 _isLoading = true;
//               });
//               _loadData();
//             },
//             backgroundColor: Colors.green,
//             child: const Icon(Icons.refresh),
//           )
//         : null,
//     );
//   }

//   Widget _buildCurrentView() {
//     switch (_currentIndex) {
//       case 0:
//         return _buildHomeView();
//       case 1:
//         return _buildHistoryView();
//       case 2:
//         return _buildProfileView();
//       default:
//         return _buildHomeView();
//     }
//   }

//   Widget _buildHomeView() {
//     return CustomScrollView(
//       slivers: [
//         _buildAppBar('Volunteer Dashboard'),
//         SliverToBoxAdapter(
//           child: _buildVolunteerProfile(),
//         ),
//         SliverToBoxAdapter(
//           child: _buildRadiusFilter(),
//         ),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
//             child: Text(
//               'Nearby Donations',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green.shade800,
//               ),
//             ),
//           ),
//         ),
//         _nearbyDonations.isEmpty
//             ? SliverFillRemaining(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.search_off_rounded,
//                         size: 80,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         'No donations found within ${_selectedRadius}km',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final donation = _nearbyDonations[index];
//                     return _buildDonationCard(donation);
//                   },
//                   childCount: _nearbyDonations.length,
//                 ),
//               ),
//       ],
//     );
//   }

//   Widget _buildHistoryView() {
//     return CustomScrollView(
//       slivers: [
//         _buildAppBar('Donation History'),
//         _pastDonations.isEmpty
//             ? SliverFillRemaining(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.history_toggle_off,
//                         size: 80,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         'No donation history yet',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final donation = _pastDonations[index];
//                     return _buildPastDonationCard(donation);
//                   },
//                   childCount: _pastDonations.length,
//                 ),
//               ),
//       ],
//     );
//   }

//   Widget _buildProfileView() {
//     return CustomScrollView(
//       slivers: [
//         _buildAppBar('Volunteer Profile'),
//         SliverToBoxAdapter(
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 60,
//                   backgroundImage: AssetImage(_volunteerProfile['avatar']),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   _volunteerProfile['name'],
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'ID: ${_volunteerProfile['volunteerID']}',
//                     style: TextStyle(
//                       color: Colors.green.shade800,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildStatCard(
//                       '${_volunteerProfile['deliveries']}',
//                       'Deliveries',
//                       Icons.delivery_dining,
//                     ),
//                     const SizedBox(width: 20),
//                     _buildStatCard(
//                       '${_volunteerProfile['rating']}',
//                       'Rating',
//                       Icons.star,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 _buildProfileSection('Bio', _volunteerProfile['bio'], Icons.description),
//                 _buildProfileSection('Contact Information', '', Icons.contact_mail),
//                 _buildInfoRow(Icons.email, 'Email', _volunteerProfile['email']),
//                 _buildInfoRow(Icons.phone, 'Phone', _volunteerProfile['phone']),
//                 _buildInfoRow(Icons.home, 'Address', _volunteerProfile['address']),
//                 _buildInfoRow(Icons.calendar_today, 'Member Since', _volunteerProfile['joinDate']),
//                 const SizedBox(height: 16),
//                 OutlinedButton(
//                   onPressed: () {
//                     // Edit profile functionality
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.green.shade700,
//                     side: BorderSide(color: Colors.green.shade700),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                   ),
//                   child: const Text('EDIT PROFILE'),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String value, String label, IconData icon) {
//     return Container(
//       width: 100,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             color: Colors.green.shade700,
//             size: 24,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileSection(String title, String content, IconData icon) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 icon,
//                 color: Colors.green.shade700,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           if (content.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               content,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, bottom: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: Colors.grey.shade600,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPastDonationCard(Map<String, dynamic> donation) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ExpansionTile(
//         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: AssetImage(donation['donorAvatar']),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     donation['donor'],
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Text(
//                     donation['foodType'],
//                     style: TextStyle(
//                       color: Colors.grey.shade700,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 donation['date'],
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 12,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(donation['status']),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   donation['status'],
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               children: [
//                 const Divider(),
//                 _buildDetailRow(
//                   Icons.shopping_basket,
//                   'Quantity:',
//                   donation['quantity'],
//                 ),
//                 const SizedBox(height: 8),
//                 _buildDetailRow(
//                   Icons.apartment,
//                   'Recipient:',
//                   donation['recipient'],
//                 ),
//                 const SizedBox(height: 8),
//                 _buildDetailRow(
//                   Icons.location_on,
//                   'Delivery Address:',
//                   donation['recipientAddress'],
//                 ),
//                 const SizedBox(height: 16),
//                 OutlinedButton(
//                   onPressed: () {
//                     // View delivery details
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.green.shade700,
//                     side: BorderSide(color: Colors.green.shade700),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.receipt_long),
//                       SizedBox(width: 8),
//                       Text('VIEW DETAILS'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar(String title) {
//     return SliverAppBar(
//       pinned: true,
//       expandedHeight: 120,
//       backgroundColor: Colors.green.shade800,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.notifications_rounded),
//               onPressed: () {
//                 // Show notifications
//                 setState(() {
//                   _hasNotifications = false;
//                 });
//               },
//             ),
//             if (_hasNotifications)
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: Container(
//                   width: 12,
//                   height: 12,
//                   decoration: const BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         IconButton(
//           icon: const Icon(Icons.settings_outlined),
//           onPressed: () {
//             // Open settings
//           },
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.green.shade900,
//                 Colors.green.shade700,
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVolunteerProfile() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.green.shade500, Colors.green.shade700],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundImage: AssetImage(_volunteerProfile['avatar']),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _volunteerProfile['name'],
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.delivery_dining,
//                             color: Colors.white,
//                             size: 14,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${_volunteerProfile['deliveries']} deliveries',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 14,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${_volunteerProfile['rating']}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.green.shade300,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               _volunteerProfile['status'],
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRadiusFilter() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Donation Search Radius',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [2, 5, 10, 15, 20].map((radius) {
//               final isSelected = _selectedRadius == radius;
//               return GestureDetector(
//                 onTap: () => _filterByRadius(radius),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: isSelected ? Colors.green : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '$radius km',
//                     style: TextStyle(
//                       color: isSelected ? Colors.white : Colors.grey.shade700,
//                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDonationCard(Map<String, dynamic> donation) {
//     return Container(
// margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header with donor info
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundImage: AssetImage(donation['donorAvatar']),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         donation['donor'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 16,
//                           ),
//                           Text(
//                             ' ${donation['rating']} • ${donation['timestamp']}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getExpiryColor(donation['expiryTime']),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.access_time,
//                         color: Colors.white,
//                         size: 12,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         donation['expiryTime'],
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Donation details
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               children: [
//                 _buildDetailRow(
//                   Icons.restaurant,
//                   'Food Type:',
//                   donation['foodType'],
//                 ),
//                 const SizedBox(height: 8),
//                 _buildDetailRow(
//                   Icons.shopping_basket,
//                   'Quantity:',
//                   donation['quantity'],
//                 ),
//                 const SizedBox(height: 8),
//                 _buildDetailRow(
//                   Icons.location_on,
//                   'Address:',
//                   donation['address'],
//                 ),
//                 const SizedBox(height: 8),
//                 _buildDetailRow(
//                   Icons.directions_walk,
//                   'Distance:',
//                   donation['distance'],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () {
//                           // Show location on map
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.green.shade700,
//                           side: BorderSide(color: Colors.green.shade700),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.map_outlined),
//                             SizedBox(width: 8),
//                             Text('VIEW LOCATION'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () => _acceptDonation(donation['id']),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green.shade700,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.check_circle_outline),
//                             SizedBox(width: 8),
//                             Text('ACCEPT'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: Colors.grey.shade600,
//         ),
//         const SizedBox(width: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//             textAlign: TextAlign.right,
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getExpiryColor(String expiryTime) {
//     final hours = int.tryParse(expiryTime.split(' ')[0]) ?? 0;
//     if (hours <= 2) {
//       return Colors.red.shade700;
//     } else if (hours <= 4) {
//       return Colors.orange.shade700;
//     } else {
//       return Colors.green.shade700;
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Delivered':
//         return Colors.green.shade700;
//       case 'In Progress':
//         return Colors.blue.shade700;
//       case 'Cancelled':
//         return Colors.red.shade700;
//       default:
//         return Colors.grey.shade700;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:kindmeals/screens/volunteer/volunteerhistory.dart';
import 'package:kindmeals/screens/volunteer/volunteerprofile.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';


class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _nearbyDonations = [];
  Map<String, dynamic> _volunteerProfile = {};
  int _selectedRadius = 5; // Default radius in km
  bool _hasNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate loading data from API
    await Future.delayed(const Duration(seconds: 1));
    
    // This would be replaced with actual API calls
    setState(() {
      _volunteerProfile = {
        'name': 'John Smith',
        'avatar': 'assets/images/volunteer1.jpg',
        'deliveries': 27,
        'rating': 4.8,
        'status': 'Available',
        'email': 'john.smith@example.com',
        'phone': '+1 (555) 123-4567',
        'address': '123 Volunteer Street, Cityville, State 12345',
        'joinDate': 'March 15, 2024',
        'volunteerID': 'VOL-12345',
        'bio': 'Passionate about reducing food waste and helping those in need. I have been volunteering with food rescue organizations for over 2 years.'
      };
      
      _nearbyDonations = [
        {
          'id': '1',
          'donor': 'Restaurant A',
          'donorAvatar': 'assets/images/restaurant1.jpg',
          'foodType': 'Mixed Indian Food',
          'quantity': '5 meals',
          'expiryTime': '3 hours',
          'distance': '1.2 km',
          'address': '123 Green St, Downtown',
          'rating': 4.7,
          'timestamp': '15 minutes ago',
        },
        {
          'id': '2',
          'donor': 'Hotel C',
          'donorAvatar': 'assets/images/restaurant3.jpg',
          'foodType': 'Continental Breakfast',
          'quantity': '8 meals',
          'expiryTime': '2 hours',
          'distance': '2.8 km',
          'address': '456 Park Ave, Midtown',
          'rating': 4.5,
          'timestamp': '32 minutes ago',
        },
        {
          'id': '3',
          'donor': 'Bakery D',
          'donorAvatar': 'assets/images/restaurant4.jpg',
          'foodType': 'Bread and Pastries',
          'quantity': '12 items',
          'expiryTime': '6 hours',
          'distance': '3.2 km',
          'address': '789 Baker St, Uptown',
          'rating': 4.9,
          'timestamp': '45 minutes ago',
        },
        {
          'id': '4',
          'donor': 'Cafe B',
          'donorAvatar': 'assets/images/restaurant2.jpg',
          'foodType': 'Sandwiches and Coffee',
          'quantity': '10 servings',
          'expiryTime': '4 hours',
          'distance': '4.5 km',
          'address': '101 Main St, Westside',
          'rating': 4.3,
          'timestamp': '1 hour ago',
        },
        {
          'id': '5',
          'donor': 'Catering E',
          'donorAvatar': 'assets/images/restaurant5.jpg',
          'foodType': 'Catered Event Leftovers',
          'quantity': '20 meals',
          'expiryTime': '5 hours',
          'distance': '4.9 km',
          'address': '202 Conference Center, Business District',
          'rating': 4.6,
          'timestamp': '1.5 hours ago',
        },
      ];
      
      _isLoading = false;
    });
  }

  Future<void> _acceptDonation(String donationId) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call to accept donation
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Update local state
    setState(() {
      _nearbyDonations.removeWhere((donation) => donation['id'] == donationId);
      _isLoading = false;
    });
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation accepted successfully! Please proceed for pickup.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _filterByRadius(int radius) {
    setState(() {
      _selectedRadius = radius;
      _isLoading = true;
    });
    
    // Simulate loading new data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // Filter donations based on radius
        // In a real app, this would be a server call
        _nearbyDonations = _nearbyDonations
            .where((donation) => double.parse(donation['distance'].split(' ')[0]) <= radius)
            .toList();
        _isLoading = false;
      });
    });
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerHistoryScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildHomeView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            _navigateToHistory();
          } else if (index == 2) {
            _navigateToProfile();
          }
        },
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh available donations
          setState(() {
            _isLoading = true;
          });
          _loadData();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHomeView() {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Volunteer Dashboard'),
        SliverToBoxAdapter(
          child: _buildVolunteerProfile(),
        ),
        SliverToBoxAdapter(
          child: _buildRadiusFilter(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
            child: Text(
              'Nearby Donations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ),
        _nearbyDonations.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No donations found within ${_selectedRadius}km',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final donation = _nearbyDonations[index];
                    return _buildDonationCard(donation);
                  },
                  childCount: _nearbyDonations.length,
                ),
              ),
      ],
    );
  }

  Widget _buildAppBar(String title) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.green.shade800,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () {
                // Show notifications
                setState(() {
                  _hasNotifications = false;
                });
              },
            ),
            if (_hasNotifications)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Open settings
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade900,
                Colors.green.shade700,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteerProfile() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(_volunteerProfile['avatar']),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _volunteerProfile['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delivery_dining,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_volunteerProfile['deliveries']} deliveries',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_volunteerProfile['rating']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _volunteerProfile['status'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donation Search Radius',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [2, 5, 10, 15, 20].map((radius) {
              final isSelected = _selectedRadius == radius;
              return GestureDetector(
                onTap: () => _filterByRadius(radius),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$radius km',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with donor info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(donation['donorAvatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation['donor'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          Text(
                            ' ${donation['rating']} • ${donation['timestamp']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getExpiryColor(donation['expiryTime']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        donation['expiryTime'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Donation details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.restaurant,
                  'Food Type:',
                  donation['foodType'],
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.shopping_basket,
                  'Quantity:',
                  donation['quantity'],
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on,
                  'Address:',
                  donation['address'],
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.directions_walk,
                  'Distance:',
                  donation['distance'],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Show location on map
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          side: BorderSide(color: Colors.green.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined),
                            SizedBox(width: 8),
                            Text('VIEW LOCATION'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptDonation(donation['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 8),
                            Text('ACCEPT'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getExpiryColor(String expiryTime) {
    final hours = int.tryParse(expiryTime.split(' ')[0]) ?? 0;
    if (hours <= 2) {
      return Colors.red.shade700;
    } else if (hours <= 4) {
      return Colors.orange.shade700;
    } else {
      return Colors.green.shade700;
    }
  }
}