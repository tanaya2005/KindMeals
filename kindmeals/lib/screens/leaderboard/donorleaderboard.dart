import 'package:flutter/material.dart';

class DonorLeaderboardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> donors;

  const DonorLeaderboardScreen({super.key, required this.donors});

  @override
  State<DonorLeaderboardScreen> createState() => _DonorLeaderboardScreenState();
}

class _DonorLeaderboardScreenState extends State<DonorLeaderboardScreen> {
  String _sortBy = 'meals'; // Default sort by meals donated
  bool _ascending = false; // Default descending order

  @override
  Widget build(BuildContext context) {
    // Create a copy of the donors list to sort
    final sortedDonors = List<Map<String, dynamic>>.from(widget.donors);
    
    // Sort the list based on current sort settings
    if (_sortBy == 'meals') {
      sortedDonors.sort((a, b) => _ascending 
          ? a['meals'].compareTo(b['meals'])
          : b['meals'].compareTo(a['meals']));
    } else if (_sortBy == 'name') {
      sortedDonors.sort((a, b) => _ascending 
          ? a['name'].compareTo(b['name'])
          : b['name'].compareTo(a['name']));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Leaderboard'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  // Toggle ascending/descending if the same sort option is selected
                  _ascending = !_ascending;
                } else {
                  // Set new sort option and default to descending for 'meals' or ascending for 'name'
                  _sortBy = value;
                  _ascending = value == 'name';
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'meals',
                child: Text('Sort by Meals Donated'),
              ),
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Container
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Donors', '${sortedDonors.length}'),
                _buildStatColumn('Total Meals', 
                    '${sortedDonors.fold<int>(0, (sum, item) => sum + (item['meals'] as int))}'),
                _buildStatColumn('Avg Donation', 
                    (sortedDonors.fold<int>(0, (sum, item) => sum + (item['meals'] as int)) / sortedDonors.length).toStringAsFixed(1)),
              ],
            ),
          ),
          
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 50, 
                  child: Text(
                    'Rank',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ),
                Expanded(
                  child: Text(
                    'Donor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Meals',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Donor List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedDonors.length,
              itemBuilder: (context, index) {
                final donor = sortedDonors[index];
                final rank = index + 1;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      children: [
                        // Rank with medal for top 3
                        SizedBox(
                          width: 50,
                          child: _buildRankWidget(rank),
                        ),
                        
                        // Avatar and donor info
                        Expanded(
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: AssetImage(donor['avatar']),
                                backgroundColor: Colors.grey.shade200,
                                child: donor.containsKey('avatar') ? null : Icon(
                                  Icons.person,
                                  color: Colors.grey.shade500,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donor['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${donor['meals']} meals donated',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Meals count with food icon
                        SizedBox(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${donor['meals']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.orange.shade800,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRankWidget(int rank) {
    if (rank <= 3) {
      // Medal for top 3
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getMedalColor(rank - 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _getMedalIcon(rank),
        ),
      );
    } else {
      // Regular rank indicator for others
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Widget _getMedalIcon(int rank) {
    switch (rank) {
      case 1:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.white, size: 24),
            Positioned(
              top: 6,
              child: Icon(Icons.restaurant, color: Colors.amber.shade200, size: 10),
            ),
          ],
        );
      case 2:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.white, size: 22),
            Positioned(
              top: 6,
              child: Icon(Icons.restaurant, color: Colors.blueGrey.shade200, size: 9),
            ),
          ],
        );
      case 3:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.white, size: 20),
            Positioned(
              top: 6,
              child: Icon(Icons.restaurant, color: Colors.brown.shade200, size: 8),
            ),
          ],
        );
      default:
        return Text(
          '$rank',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
    }
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
        return Colors.grey.shade500;
    }
  }
}