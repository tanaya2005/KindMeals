import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'donation_detail_screen.dart';

class ViewDonationsScreen extends StatefulWidget {
  const ViewDonationsScreen({super.key});

  @override
  State<ViewDonationsScreen> createState() => _ViewDonationsScreenState();
}

class _ViewDonationsScreenState extends State<ViewDonationsScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Fetching live donations...');
      final donations = await _apiService.getLiveDonations();
      print('Fetched ${donations.length} donations');

      setState(() {
        _donations = donations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching donations: $e');
      String errorMsg = e.toString().replaceAll('Exception: ', '');

      // Provide more user-friendly error messages
      if (errorMsg.contains('User not found in database')) {
        errorMsg =
            'Your profile was not found. Please ensure you are registered as a recipient to view donations.';
      } else if (errorMsg.contains('Failed to get live donations')) {
        errorMsg =
            'Unable to load donations at this time. Please try again later.';
      } else if (errorMsg.contains('No authenticated user found')) {
        errorMsg = 'Please sign in to view donations.';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptDonation(String donationId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Accepting donation $donationId');
      await _apiService.acceptDonation(donationId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation accepted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );

      // Refresh the donations list
      await _fetchDonations();
    } catch (e) {
      print('Error accepting donation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
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
      appBar: AppBar(
        title: const Text('Available Donations'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDonations,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            if (_errorMessage.contains('profile was not found')) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                icon: const Icon(Icons.person),
                label: const Text('Go to Profile'),
              ),
            ],
          ],
        ),
      );
    }

    if (_donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fastfood_outlined,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No available donations found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new donations',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _donations.length,
        itemBuilder: (context, index) {
          final donation = _donations[index];
          return _buildDonationCard(donation);
        },
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final String foodName = donation['foodName'] ?? 'Unknown';
    final String description = donation['description'] ?? 'No description';
    final String foodType = donation['foodType'] ?? 'Unknown';
    final String address =
        donation['location']?['address'] ?? 'Unknown location';
    final String donorName = donation['donorName'] ?? 'Anonymous';

    // Format expiry date
    final DateTime expiryDateTime = donation['expiryDateTime'] != null
        ? DateTime.parse(donation['expiryDateTime'])
        : DateTime.now();
    final String expiryDate =
        '${expiryDateTime.day}/${expiryDateTime.month}/${expiryDateTime.year} at ${expiryDateTime.hour}:${expiryDateTime.minute.toString().padLeft(2, '0')}';

    // Get image URL if available - check multiple possible field names
    String? imageUrl;
    if (donation.containsKey('imageUrl') && donation['imageUrl'] != null) {
      imageUrl = donation['imageUrl'];
    } else if (donation.containsKey('foodImage') &&
        donation['foodImage'] != null) {
      imageUrl = donation['foodImage'];
    }

    print('DEBUG: Donation image URL: $imageUrl');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailScreen(
                donation: donation,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.network(
                  ApiConfig.getImageUrl(imageUrl),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    print(
                        'Image URL attempted: ${ApiConfig.getImageUrl(imageUrl)}');
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.fastfood,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: const Icon(
                  Icons.fastfood,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: foodType == 'veg'
                          ? Colors.green[100]
                          : foodType == 'nonveg'
                              ? Colors.red[100]
                              : Colors.amber[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      foodType.toUpperCase(),
                      style: TextStyle(
                        color: foodType == 'veg'
                            ? Colors.green[800]
                            : foodType == 'nonveg'
                                ? Colors.red[800]
                                : Colors.amber[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quantity: ${donation['quantity'] ?? 'Unknown'} servings',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Donated by: $donorName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Expires on: $expiryDate'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => _acceptDonation(donation['_id']),
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Show more details in a dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(foodName),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Type: ${foodType.toUpperCase()}'),
                                    const SizedBox(height: 8),
                                    Text('Description: $description'),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Quantity: ${donation['quantity']} servings'),
                                    const SizedBox(height: 8),
                                    Text('Donor: $donorName'),
                                    const SizedBox(height: 8),
                                    Text('Location: $address'),
                                    const SizedBox(height: 8),
                                    Text('Expires on: $expiryDate'),
                                    if (donation['needsVolunteer'] == true) ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        'This donation needs volunteer assistance for delivery',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _acceptDonation(donation['_id']);
                                  },
                                  child: const Text('Accept Donation'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Details'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
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
    );
  }
}
