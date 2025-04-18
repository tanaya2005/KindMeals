import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import '../../utils/date_time_helper.dart';
import 'volunteerhistory.dart';
import 'volunteerprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      // Get volunteer profile data from API
      try {
        final userProfile = await _apiService.getDirectUserProfile();
        if (userProfile['profile'] != null) {
          setState(() {
            _volunteerProfile = userProfile['profile'];
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching volunteer profile: $e');
        }
        // Use placeholder data when profile fetch fails
        setState(() {
          _volunteerProfile = {
            'volunteerName': 'Volunteer',
            'totalRatings': 0,
            'rating': 0.0,
          };
        });
      }

      // Get accepted donations that need volunteer delivery
      try {
        if (kDebugMode) {
          print('Fetching volunteer opportunities...');
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            print('Current volunteer user: ${user.uid}, ${user.email}');
          } else {
            print('No user signed in - cannot fetch opportunities');
          }
        }

        final opportunities =
            await _apiService.getAcceptedDonationsForVolunteer();

        if (kDebugMode) {
          print('Received ${opportunities.length} opportunities from API');
          if (opportunities.isNotEmpty) {
            print('Sample opportunity: ${opportunities[0]}');
          }
        }

        // Validate each opportunity to ensure it has all required fields
        final validOpportunities = opportunities.where((donation) {
          // Check for essential fields
          return donation.containsKey('_id') &&
              donation.containsKey('foodName') &&
              donation.containsKey('donorName');
        }).toList();

        if (validOpportunities.length < opportunities.length && kDebugMode) {
          print(
              'Filtered out ${opportunities.length - validOpportunities.length} invalid opportunities');
        }

        setState(() {
          _deliveryOpportunities = validOpportunities;
        });

        if (validOpportunities.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No delivery opportunities available right now. Check back later!'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching delivery opportunities: $e');
        }

        setState(() {
          _deliveryOpportunities = [];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error loading opportunities: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _acceptDeliveryOpportunity(String acceptedDonationId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Call API to accept donation delivery
      await _apiService.volunteerAcceptDelivery(
        acceptedDonationId: acceptedDonationId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh data
      _loadData();
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting delivery: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to accept delivery: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
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
            : _buildDashboardView(),
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

  Widget _buildDashboardView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildVolunteerProfile(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '${_deliveryOpportunities.length} Delivery ${_deliveryOpportunities.length == 1 ? 'Request' : 'Requests'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                            Icons.no_food,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No delivery requests available right now',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Delivery requests appear here when recipients need volunteer assistance.\n\nRecipients must accept donations and select "Need Volunteer Help" when accepting.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _navigateToVolunteerHistory,
                                icon: const Icon(Icons.history),
                                label: const Text('View History'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _buildDeliveryRequestCard(_deliveryOpportunities[index]);
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
    // Extract volunteer name and rating from profile data
    final name = _volunteerProfile['volunteerName'] ?? 'Volunteer';
    final deliveries = _volunteerProfile['totalRatings'] ?? 0;
    final rating = _volunteerProfile['rating'] ?? 0.0;

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
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 36,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$deliveries Deliveries Completed',
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
                  rating.toStringAsFixed(1),
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

  Widget _buildDeliveryRequestCard(Map<String, dynamic> donation) {
    // Get donor information
    final donorInfo = donation['donorInfo'] ?? {};
    final donorName =
        donation['donorName'] ?? donorInfo['donorName'] ?? 'Unknown Donor';
    final donorContact = donation['donorContact'] ??
        donation['donorInfo']?['donorContact'] ??
        'Contact not available';
    final donorAddress = donation['donorAddress'] ??
        donation['location']?['address'] ??
        donation['donorInfo']?['donorAddress'] ??
        'Address not available';

    // Get recipient information
    final recipientInfo = donation['recipientInfo'] ?? {};
    final recipientName = recipientInfo['recipientName'] ??
        donation['recipientName'] ??
        'Unknown Recipient';
    final recipientContact = recipientInfo['recipientContact'] ??
        donation['recipientContact'] ??
        'Contact not available';
    final recipientAddress = recipientInfo['recipientAddress'] ??
        donation['recipientAddress'] ??
        'Address not available';

    // Other donation details
    final acceptedTime = _getAcceptedTimeString(donation['acceptedAt']);
    final foodName = donation['foodName'] ?? 'Food Donation';
    final quantity = donation['quantity'] ?? 0;
    final description = donation['description'] ?? 'No description provided';
    final expiryDateTime = donation['expiryDateTime'];
    final foodType = donation['foodType']?.toString().toLowerCase() ?? '';
    
    // Get food image if available
    String? imageUrl;
    if (donation['imageUrl'] != null &&
        donation['imageUrl'].toString().isNotEmpty) {
      imageUrl = '${ApiService.baseUrl}${donation['imageUrl']}';
    }

    // Food type icon and color mapping
    final (IconData foodTypeIcon, Color foodTypeColor) = _getFoodTypeIcon(foodType);

    // Card state management
    final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (context, expanded, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Food type icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: foodTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        foodTypeIcon,
                        color: foodTypeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Food name and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: foodTypeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: foodTypeColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  foodType.isEmpty ? 'MIXED' : foodType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: foodTypeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people_alt_outlined,
                                      size: 10,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "$quantity servings",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                acceptedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Donor & Recipient Information Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Donor information
                    _buildContactCard(
                      title: 'Donor',
                      name: donorName,
                      contact: donorContact,
                      address: donorAddress,
                      iconColor: Colors.green.shade700,
                      icon: Icons.store,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recipient information
                    _buildContactCard(
                      title: 'Recipient',
                      name: recipientName,
                      contact: recipientContact,
                      address: recipientAddress,
                      iconColor: Colors.orange.shade700,
                      icon: Icons.person,
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(height: 1, color: Colors.grey.shade200),

              // View Details button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Expand/Collapse button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          isExpanded.value = !isExpanded.value;
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: expanded 
                              ? Colors.grey.shade100 
                              : Colors.blue.shade50,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: expanded 
                                  ? Colors.grey.shade300 
                                  : Colors.blue.shade200,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              expanded 
                                  ? Icons.keyboard_arrow_up 
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: expanded 
                                  ? Colors.grey.shade700 
                                  : Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              expanded ? 'Hide Details' : 'View Details',
                              style: TextStyle(
                                color: expanded 
                                    ? Colors.grey.shade700 
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded section with food details
              if (expanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food image if available
                      if (imageUrl != null)
                        Container(
                          height: 180,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image not available',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Food description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 18,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Food Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                            
                            if (expiryDateTime != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expires on: ${_formatDateTime(expiryDateTime)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Accept Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: donation['_id'] != null
                      ? () => _acceptDeliveryOpportunity(donation['_id'])
                      : null,
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('ACCEPT DELIVERY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactCard({
    required String title,
    required String name,
    required String contact,
    required String address,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Contact details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contact,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.call,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  onPressed: () {
                    // Call functionality would go here
                  },
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  iconSize: 16,
                  padding: const EdgeInsets.all(8),
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to format time since acceptance
  String _getAcceptedTimeString(String? acceptedAt) {
    if (acceptedAt == null) return 'Recently';
    try {
      final acceptedTime = DateTime.parse(acceptedAt);
      final now = DateTime.now();
      final difference = now.difference(acceptedTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return 'Recently';
    }
  }

  // Helper function to get food type icon and color
  (IconData, Color) _getFoodTypeIcon(String foodType) {
    if (foodType == 'veg') {
      return (Icons.eco, Colors.green.shade600);
    } else if (foodType == 'nonveg') {
      return (FontAwesomeIcons.drumstickBite, Colors.red.shade600);
    } else if (foodType == 'jain') {
      return (Icons.spa, Colors.green.shade800);
    } else {
      return (Icons.restaurant, Colors.grey.shade700);
    }
  }

  // Helper method to format date time in IST
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown';
    try {
      if (kDebugMode) {
        print('===== FORMATTING DATE IN VOLUNTEER DASHBOARD =====');
        print('Input date string from API: $dateTimeStr');
      }

      // Parse the string to a DateTime object and convert to local time (IST)
      final dateTime = DateTimeHelper.parseToIST(dateTimeStr);

      if (kDebugMode) {
        print('Parsed to IST DateTime: $dateTime');
        print('Formatting using DateTimeHelper.formatDateTime');
      }

      // Format using DateTimeHelper to ensure consistent display
      final formatted = DateTimeHelper.formatDateTime(dateTime);

      if (kDebugMode) {
        print('Final formatted output: $formatted');
        print('===========================================');
      }

      return formatted;
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date in volunteer dashboard: $e');
      }
      return 'Unknown';
    }
  }
}