import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'package:intl/intl.dart';

class RecipientHistoryScreen extends StatefulWidget {
  const RecipientHistoryScreen({super.key});

  @override
  State<RecipientHistoryScreen> createState() => _RecipientHistoryScreenState();
}

class _RecipientHistoryScreenState extends State<RecipientHistoryScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _acceptedDonations = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAcceptedDonations();
  }

  Future<void> _fetchAcceptedDonations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Fetching recipient donation history...');
      final donations = await _apiService.getRecipientDonations();
      print('Fetched ${donations.length} accepted donations');

      setState(() {
        _acceptedDonations = donations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching accepted donations: $e');
      String errorMsg = e.toString().replaceAll('Exception: ', '');

      // Provide more user-friendly error messages
      if (errorMsg.contains('Not found')) {
        errorMsg = 'No donation history found. Please try again later.';
      } else if (errorMsg.contains('No authenticated user found')) {
        errorMsg = 'Please sign in to view your donation history.';
      } else {
        // General error message for any other error
        errorMsg = 'Unable to load donations. Please try again later.';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
        // Initialize with empty list to prevent null errors
        _acceptedDonations = [];
      });
    }
  }

  Future<void> _addFeedback(String donationId, String currentFeedback) async {
    final TextEditingController feedbackController =
        TextEditingController(text: currentFeedback);

    final feedbackResult = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Feedback'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'Share your experience about this donation...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, feedbackController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (feedbackResult != null && feedbackResult.isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _apiService.addFeedback(donationId, feedbackResult);

        // Update the donation in the local list
        await _fetchAcceptedDonations();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error adding feedback: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error submitting feedback: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAcceptedDonations,
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
              onPressed: _fetchAcceptedDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_acceptedDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No donation history found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accept donations to see them here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the ViewDonationsScreen
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Donations'),
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
      onRefresh: _fetchAcceptedDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _acceptedDonations.length,
        itemBuilder: (context, index) {
          final donation = _acceptedDonations[index];
          return _buildDonationCard(donation);
        },
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final String foodName = donation['foodName'] ?? 'Unknown';
    final String description = donation['description'] ?? 'No description';
    final String foodType = donation['foodType'] ?? 'Unknown';
    final String donorName = donation['donorName'] ?? 'Anonymous';
    final String deliveredBy = donation['deliveredby'] ?? 'Self-pickup';
    final String feedback = donation['feedback'] ?? '';

    // Format dates
    final DateTime acceptedAt = donation['acceptedAt'] != null
        ? DateTime.parse(donation['acceptedAt'])
        : DateTime.now();
    final String acceptedDate = DateFormat('MM/dd/yyyy').format(acceptedAt);
    final String acceptedTime = DateFormat('hh:mm a').format(acceptedAt);

    final DateTime expiryDateTime = donation['expiryDateTime'] != null
        ? DateTime.parse(donation['expiryDateTime'])
        : DateTime.now();
    final String expiryDate = DateFormat('MM/dd/yyyy').format(expiryDateTime);

    // Get image URL if available
    String? imageUrl;
    if (donation.containsKey('imageUrl') && donation['imageUrl'] != null) {
      imageUrl = donation['imageUrl'];
    }

    // Determine the card border color based on how recent the donation is
    final int daysSinceAccepted = DateTime.now().difference(acceptedAt).inDays;
    Color borderColor = Colors.green;
    if (daysSinceAccepted <= 1) {
      borderColor = Colors.green;
    } else if (daysSinceAccepted <= 7) {
      borderColor = Colors.blue;
    } else {
      borderColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      elevation: 3,
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
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    height: 150,
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
              height: 100,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        foodName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                  ],
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                    const Icon(Icons.access_time,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Accepted on: $acceptedDate at $acceptedTime',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.delivery_dining,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Delivery method: $deliveredBy',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Feedback section
                if (feedback.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Feedback:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feedback,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _addFeedback(donation['_id'], feedback),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Feedback'),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addFeedback(donation['_id'], ''),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Add Feedback'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
