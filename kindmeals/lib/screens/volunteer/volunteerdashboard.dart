import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import 'volunteerhistory.dart';
import 'volunteerprofile.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _deliveryOpportunities = [];
  Map<String, dynamic> _volunteerProfile = {};
  int _selectedRadius = 5; // Default radius in km
  bool _hasNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get volunteer profile data
      // This would be replaced with actual API call to get volunteer details
      // For demo, using mock data
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
        'bio': 'Passionate about reducing food waste and helping those in need.'
      };

      // Get delivery opportunities from API
      try {
        final opportunities = await _apiService.getVolunteerOpportunities();
        setState(() {
          _deliveryOpportunities = opportunities;
        });
      } catch (e) {
        print('Error fetching volunteer opportunities: $e');
        // Use placeholder data for now if API fails
        setState(() {
          _deliveryOpportunities = [
            {
              '_id': '1',
              'donorName': 'Restaurant A',
              'foodName': 'Mixed Indian Food',
              'quantity': 5,
              'expiryDateTime': DateTime.now()
                  .add(const Duration(hours: 3))
                  .toIso8601String(),
              'location': {
                'address': '123 Green St, Downtown',
              },
              'timeOfUpload': DateTime.now()
                  .subtract(const Duration(minutes: 15))
                  .toIso8601String(),
            },
            {
              '_id': '2',
              'donorName': 'Hotel C',
              'foodName': 'Continental Breakfast',
              'quantity': 8,
              'expiryDateTime': DateTime.now()
                  .add(const Duration(hours: 2))
                  .toIso8601String(),
              'location': {
                'address': '456 Park Ave, Midtown',
              },
              'timeOfUpload': DateTime.now()
                  .subtract(const Duration(minutes: 32))
                  .toIso8601String(),
            },
          ];
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerHistoryScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerProfileScreen()),
    );
  }

  void _acceptDeliveryOpportunity(String donationId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Call API to accept donation delivery
      await _apiService.volunteerAcceptDonation(
        donationId: donationId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh data
      _loadData();
    } catch (e) {
      print('Error accepting delivery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to accept delivery: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
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
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            toolbarHeight: 70,
            backgroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Delivery Opportunities',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Help deliver surplus food to those in need',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Show notifications
                    },
                    color: Colors.black87,
                  ),
                  if (_hasNotifications)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildVolunteerProfile(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_deliveryOpportunities.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No delivery opportunities available right now',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Check back later or adjust your search radius',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _buildOpportunityCard(_deliveryOpportunities[index]);
              },
              childCount: _deliveryOpportunities.isEmpty
                  ? 1
                  : _deliveryOpportunities.length,
            ),
          ),
        ],
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_volunteerProfile['deliveries']} Deliveries Completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _volunteerProfile['rating'].toString(),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opportunity) {
    // Calculate time left for expiry
    final expiryTime = DateTime.parse(opportunity['expiryDateTime']);
    final now = DateTime.now();
    final difference = expiryTime.difference(now);

    // Format the time difference for display
    String timeLeft;
    if (difference.inHours > 0) {
      timeLeft = '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      timeLeft = '${difference.inMinutes} minutes';
    } else {
      timeLeft = 'Expiring soon';
    }

    // Calculate how long ago the donation was posted
    final uploadTime = DateTime.parse(opportunity['timeOfUpload']);
    final uploadDifference = now.difference(uploadTime);
    String postedTime;

    if (uploadDifference.inDays > 0) {
      postedTime = '${uploadDifference.inDays} days ago';
    } else if (uploadDifference.inHours > 0) {
      postedTime = '${uploadDifference.inHours} hours ago';
    } else if (uploadDifference.inMinutes > 0) {
      postedTime = '${uploadDifference.inMinutes} minutes ago';
    } else {
      postedTime = 'Just now';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.restaurant, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity['donorName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Posted $postedTime',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: difference.inHours < 2
                        ? Colors.red.shade100
                        : Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Expires in $timeLeft',
                    style: TextStyle(
                      color: difference.inHours < 2
                          ? Colors.red.shade700
                          : Colors.amber.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.food_bank, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opportunity['foodName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        Icons.food_bank_outlined,
                        'Quantity',
                        opportunity['quantity'].toString() + ' servings',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        Icons.location_on_outlined,
                        'Location',
                        opportunity['location']['address']
                            .toString()
                            .split(',')[0],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  opportunity['description'] ?? 'No description provided',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _acceptDeliveryOpportunity(opportunity['_id']),
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('ACCEPT DELIVERY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
