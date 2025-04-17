import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import 'volunteerhistory.dart';
import 'volunteerprofile.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _deliveryOpportunities = [];
  Map<String, dynamic> _volunteerProfile = {};
  int _selectedRadius = 5; // Default radius in km
  bool _hasNotifications = true;
  int _selectedIndex = 0;

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
      try {
        final profile = await _apiService.getDirectUserProfile();
        if (profile != null && profile['profile'] != null) {
          setState(() {
            _volunteerProfile = profile['profile'];
          });
        }
      } catch (e) {
        print('Error fetching volunteer profile: $e');
        // Use placeholder data if profile fetch fails
        _volunteerProfile = {
          'volunteerName': 'Volunteer',
          'rating': 0,
          'totalRatings': 0,
        };
      }

      // Get delivery opportunities from API
      try {
        final opportunities = await _apiService.getVolunteerOpportunities();
        setState(() {
          _deliveryOpportunities = opportunities;
        });
      } catch (e) {
        print('Error fetching volunteer opportunities: $e');
        setState(() {
          _deliveryOpportunities = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error loading opportunities: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    // Food type icon
    IconData foodTypeIcon = Icons.restaurant;
    Color foodTypeColor = Colors.grey;

    if (opportunity['foodType'] == 'veg') {
      foodTypeIcon = Icons.eco;
      foodTypeColor = Colors.green;
    } else if (opportunity['foodType'] == 'nonveg') {
      foodTypeIcon = FontAwesomeIcons.drumstickBite;
      foodTypeColor = Colors.red;
    } else if (opportunity['foodType'] == 'jain') {
      foodTypeIcon = Icons.spa;
      foodTypeColor = Colors.green.shade800;
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
                    Icon(foodTypeIcon, size: 18, color: foodTypeColor),
                    const SizedBox(width: 8),
                    Text(
                      opportunity['foodType']?.toString()?.toUpperCase() ??
                          'FOOD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: foodTypeColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.people, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Serves ${opportunity['quantity']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity['foodName'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  opportunity['description'] ?? 'No description provided',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        opportunity['location']?['address'] ??
                            'Address not available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        _acceptDeliveryOpportunity(opportunity['_id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Accept Delivery',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  // Navigation to other screens
  void _navigateToVolunteerHistory() {
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

  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Do you want to logout?'),
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

        if (result == true) {
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
        appBar: AppBar(
          title: const Text('Volunteer Dashboard'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logOut,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: _selectedIndex,
                children: [
                  // Opportunities Tab
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: _deliveryOpportunities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.no_food,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No delivery opportunities',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for new donations',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _loadData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(top: 8, bottom: 72),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delivery_dining,
                                        color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_deliveryOpportunities.length} Delivery Opportunities',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ..._deliveryOpportunities
                                  .map(_buildOpportunityCard)
                                  .toList(),
                            ],
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) {
              // Already on dashboard
              setState(() {
                _selectedIndex = 0;
              });
            } else if (index == 1) {
              // Go to history
              _navigateToVolunteerHistory();
            } else if (index == 2) {
              // Go to profile
              _navigateToProfile();
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedItemColor: Colors.green,
          elevation: 8,
        ),
      ),
    );
  }
}
