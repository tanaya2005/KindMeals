import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final donations = await _apiService.getLiveDonations();
      setState(() {
        _donations = donations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Donations'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDonations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDonations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _donations.isEmpty
                  ? const Center(
                      child: Text('No donations available'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDonations,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _donations.length,
                        itemBuilder: (context, index) {
                          final donation = _donations[index];
                          return DonationCard(
                            donation: donation,
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
                          );
                        },
                      ),
                    ),
    );
  }
}

class DonationCard extends StatelessWidget {
  final Map<String, dynamic> donation;
  final VoidCallback onTap;

  const DonationCard({
    super.key,
    required this.donation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      donation['foodName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getFoodTypeColor(donation['foodType']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      donation['foodType'].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Quantity: ${donation['quantity']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                donation['description'],
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      donation['location']['address'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Expires: ${_formatDateTime(donation['expiryDateTime'])}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (donation['needsVolunteer']) ...[
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.volunteer_activism, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Volunteer needed for delivery',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
