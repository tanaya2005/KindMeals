import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class DonationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> donation;

  const DonationDetailScreen({
    super.key,
    required this.donation,
  });

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  // Helper to get image URL from donation data
  String? _getImageUrl() {
    if (widget.donation.containsKey('imageUrl') &&
        widget.donation['imageUrl'] != null &&
        widget.donation['imageUrl'].toString().isNotEmpty) {
      return widget.donation['imageUrl'];
    }
    if (widget.donation.containsKey('foodImage') &&
        widget.donation['foodImage'] != null &&
        widget.donation['foodImage'].toString().isNotEmpty) {
      return widget.donation['foodImage'];
    }
    return null;
  }

  Future<void> _acceptDonation() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _apiService.acceptDonation(widget.donation['_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting donation: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = _getImageUrl();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    Image.network(
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.donation['foodName'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getFoodTypeColor(
                                    widget.donation['foodType']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.donation['foodType'].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.restaurant,
                          'Quantity',
                          '${widget.donation['quantity']} meals',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.access_time,
                          'Expires',
                          _formatDateTime(widget.donation['expiryDateTime']),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.location_on,
                          'Pickup Location',
                          widget.donation['location']['address'],
                        ),
                        if (widget.donation['needsVolunteer']) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.volunteer_activism,
                            'Volunteer Needed',
                            'Yes - for delivery assistance',
                            iconColor: Colors.orange,
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.donation['description'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _acceptDonation,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Accept Donation',
                              style: TextStyle(
                                fontSize: 16,
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
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.green),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Color _getFoodTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'veg':
        return Colors.green;
      case 'nonveg':
        return Colors.red;
      case 'jain':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
