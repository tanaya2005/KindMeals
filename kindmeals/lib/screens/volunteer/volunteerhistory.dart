import 'package:flutter/material.dart';
import 'package:kindmeals/screens/volunteer/volunteerdashboard.dart';
import 'package:kindmeals/screens/volunteer/volunteerprofile.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';


class VolunteerHistoryScreen extends StatefulWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  State<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
}

class _VolunteerHistoryScreenState extends State<VolunteerHistoryScreen> {
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _pastDonations = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    // Simulate loading data from API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      // Load past donations for history tab
      _pastDonations = [
        {
          'id': '101',
          'donor': 'Italian Restaurant',
          'donorAvatar': 'assets/images/restaurant2.jpg',
          'foodType': 'Pizza and Pasta',
          'quantity': '8 meals',
          'date': 'Apr 10, 2025',
          'status': 'Delivered',
          'recipient': 'Downtown Shelter',
          'recipientAddress': '789 Hope St, Downtown',
        },
        {
          'id': '102',
          'donor': 'Grocery Store B',
          'donorAvatar': 'assets/images/restaurant3.jpg',
          'foodType': 'Fresh Produce and Dairy',
          'quantity': '15 items',
          'date': 'Apr 8, 2025',
          'status': 'Delivered',
          'recipient': 'Community Center',
          'recipientAddress': '456 Main St, Eastside',
        },
        {
          'id': '103',
          'donor': 'Bakery A',
          'donorAvatar': 'assets/images/restaurant4.jpg',
          'foodType': 'Bread and Pastries',
          'quantity': '25 items',
          'date': 'Apr 5, 2025',
          'status': 'Delivered',
          'recipient': 'Family Shelter',
          'recipientAddress': '101 Care Lane, Northside',
        },
        {
          'id': '104',
          'donor': 'Catering Service',
          'donorAvatar': 'assets/images/restaurant5.jpg',
          'foodType': 'Mixed Buffet Items',
          'quantity': '30 servings',
          'date': 'Apr 2, 2025',
          'status': 'Delivered',
          'recipient': 'Youth Center',
          'recipientAddress': '222 Youth Way, Westside',
        },
        {
          'id': '105',
          'donor': 'Hotel Breakfast',
          'donorAvatar': 'assets/images/restaurant1.jpg',
          'foodType': 'Continental Breakfast',
          'quantity': '12 servings',
          'date': 'Mar 29, 2025',
          'status': 'Delivered',
          'recipient': 'Women\'s Shelter',
          'recipientAddress': '555 Safe Haven, Midtown',
        },
      ];
      
      _isLoading = false;
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerHomeScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildHistoryView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            _navigateToHome();
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
          // Refresh history
          setState(() {
            _isLoading = true;
          });
          _loadHistoryData();
        },
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHistoryView() {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Donation History'),
        _pastDonations.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No donation history yet',
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
                    final donation = _pastDonations[index];
                    return _buildPastDonationCard(donation);
                  },
                  childCount: _pastDonations.length,
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
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // Show filter dialog
            _showFilterDialog();
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Show more options menu
            _showMoreOptionsMenu();
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All Donations', true),
            _buildFilterOption('Last 7 Days', false),
            _buildFilterOption('Last 30 Days', false),
            _buildFilterOption('By Status', false),
            _buildFilterOption('By Recipient', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // Apply filters
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('APPLY'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return Row(
      children: [
        Radio(
          value: isSelected,
          groupValue: true,
          onChanged: (_) {},
          activeColor: Colors.green.shade700,
        ),
        Text(label),
      ],
    );
  }

  void _showMoreOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuOption(Icons.download, 'Export History'),
            _buildMenuOption(Icons.delete_outline, 'Clear History'),
            _buildMenuOption(Icons.sort, 'Sort By'),
            _buildMenuOption(Icons.help_outline, 'Help'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // Handle menu option
      },
    );
  }

  Widget _buildPastDonationCard(Map<String, dynamic> donation) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
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
                  Text(
                    donation['foodType'],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                donation['date'],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(donation['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  donation['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(),
                _buildDetailRow(
                  Icons.shopping_basket,
                  'Quantity:',
                  donation['quantity'],
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.apartment,
                  'Recipient:',
                  donation['recipient'],
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on,
                  'Delivery Address:',
                  donation['recipientAddress'],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Share donation details
                          _showShareOptions(donation);
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
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('SHARE'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // View delivery details
                          _showDeliveryDetails(donation);
                        },
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
                            Icon(Icons.receipt_long),
                            SizedBox(width: 8),
                            Text('VIEW DETAILS'),
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

  void _showShareOptions(Map<String, dynamic> donation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Delivery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share your successful delivery of ${donation['foodType']} to ${donation['recipient']}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.message, 'Message'),
                _buildShareOption(Icons.email, 'Email'),
                _buildShareOption(Icons.facebook, 'Facebook'),
                _buildShareOption(Icons.link, 'Copy Link'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          child: Icon(
            icon,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showDeliveryDetails(Map<String, dynamic> donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Delivery Details'),
            backgroundColor: Colors.green.shade800,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(donation['donorAvatar']),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donation['donor'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Donation ID: ${donation['id']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoField('Food Type', donation['foodType']),
                        _buildInfoField('Quantity', donation['quantity']),
                        _buildInfoField('Delivery Date', donation['date']),
                        _buildInfoField('Status', donation['status'], isStatus: true),
                        const Divider(height: 32),
                        _buildInfoField('Recipient', donation['recipient']),
                        _buildInfoField('Delivery Address', donation['recipientAddress']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Delivery Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPhotoThumbnail(),
                      _buildPhotoThumbnail(),
                      _buildPhotoThumbnail(),
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Delivery Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Delivery was completed successfully. The food was received by the staff at the ${donation['recipient']} and they expressed gratitude for the donation.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Generate a receipt or certificate
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('GENERATE CERTIFICATE'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail() {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/images/placeholder.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(value),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green.shade700;
      case 'In Progress':
        return Colors.blue.shade700;
      case 'Cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}