import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Demo data for volunteers
final List<Map<String, dynamic>> demoVolunteers = [
  {
    'name': 'Emma Thompson',
    'since': '2023',
    'rating': 4.8,
    'avatar': 'https://via.placeholder.com/150',
    'donations': 47,
  },
  {
    'name': 'James Wilson',
    'since': '2022',
    'rating': 4.6,
    'avatar': 'https://via.placeholder.com/150',
    'donations': 63,
  },
  {
    'name': 'Sarah Johnson',
    'since': '2023',
    'rating': 4.9,
    'avatar': 'https://via.placeholder.com/150',
    'donations': 32,
  },
  {
    'name': 'Michael Chen',
    'since': '2021',
    'rating': 4.7,
    'avatar': 'https://via.placeholder.com/150',
    'donations': 78,
  },
  {
    'name': 'Olivia Rodriguez',
    'since': '2022',
    'rating': 4.5,
    'avatar': 'https://via.placeholder.com/150',
    'donations': 41,
  },
  {
    'name': 'William Davis',
    'since': '2023',
    'rating': 4.4,
    'avatar': 'https://via.placeholder.com/150',
    'donations': 28,
  },
  {
    'name': 'Lisa Kumar',
    'since': '2021',
    'rating': 4.9,
    'avatar': 'https://via.placeholder.com/150',
    'donations': 85,
  },
];

// Motivational quotes and content for carousel
final List<Map<String, dynamic>> motivationalContent = [
  {
    'title': 'Make A Difference',
    'description': 'Every delivery you make directly impacts someone in need.',
    'icon': Icons.favorite,
    'color': Colors.red.shade100,
    'iconColor': Colors.red,
  },
  {
    'title': 'Join Our Community',
    'description': 'Connect with like-minded individuals committed to fighting food waste.',
    'icon': Icons.people,
    'color': Colors.blue.shade100,
    'iconColor': Colors.blue,
  },
  {
    'title': 'Flexible Schedule',
    'description': 'Volunteer when it works for you - even just a few hours makes a difference.',
    'icon': Icons.access_time,
    'color': Colors.purple.shade100,
    'iconColor': Colors.purple,
  },
  {
    'title': 'Environmental Impact',
    'description': 'Help reduce food waste and lower carbon emissions with every delivery.',
    'icon': Icons.eco,
    'color': Colors.green.shade100,
    'iconColor': Colors.green,
  },
];

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteers'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Top Volunteers'),
            Tab(text: 'Leaderboard'),
          ],
          indicatorColor: Colors.green,
          labelColor: Colors.green,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVolunteersTab(),
          _buildLeaderboardTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showVolunteerApplicationForm(context);
        },
        icon: const Icon(Icons.volunteer_activism),
        label: const Text('Become a Volunteer'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildVolunteersTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Motivational Carousel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why Volunteer With Us?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 160,
                    viewportFraction: 0.9,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                  ),
                  items: motivationalContent.map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: item['color'],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item['icon'],
                                  size: 40,
                                  color: item['iconColor'],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['description'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: motivationalContent.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentCarouselIndex == entry.key
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Our Volunteer Heroes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Volunteer Cards
          ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: demoVolunteers.length,
            itemBuilder: (context, index) {
              final volunteer = demoVolunteers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          volunteer['avatar'],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              volunteer['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Volunteer since ${volunteer['since']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildRatingStars(volunteer['rating']),
                                const SizedBox(width: 8),
                                Text('${volunteer['rating']}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${volunteer['donations']} deliveries completed',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showContactDialog(context, volunteer['name']);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        child: const Text('Contact'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Sort volunteers by donations in descending order
    final sortedVolunteers = List<Map<String, dynamic>>.from(demoVolunteers);
    sortedVolunteers.sort((a, b) => b['donations'].compareTo(a['donations']));

    return Column(
      children: [
        // Stats Container
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
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
              _buildStatColumn('Total Volunteers', '${sortedVolunteers.length}'),
              _buildStatColumn(
                'Total Deliveries',
                '${sortedVolunteers.fold<int>(0, (sum, item) => sum + (item['donations'] as int))}',
              ),
              _buildStatColumn(
                'Avg Deliveries',
                (sortedVolunteers.fold<int>(0, (sum, item) => sum + (item['donations'] as int)) /
                        sortedVolunteers.length)
                    .toStringAsFixed(1),
              ),
            ],
          ),
        ),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  'Rank',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Volunteer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'Deliveries',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Volunteer List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sortedVolunteers.length,
            itemBuilder: (context, index) {
              final volunteer = sortedVolunteers[index];
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

                      // Avatar and volunteer info
                      Expanded(
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(volunteer['avatar']),
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const SizedBox(width: 16),
                            // Name and subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    volunteer['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${volunteer['donations']} deliveries made',
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

                      // Donations count
                      SizedBox(
                        width: 80,
                        child: Text(
                          '${volunteer['donations']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
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
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
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
              offset: const Offset(0, 2),
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
        return const Icon(Icons.emoji_events, color: Colors.white, size: 24);
      case 2:
        return const Icon(Icons.emoji_events, color: Colors.white, size: 22);
      case 3:
        return const Icon(Icons.emoji_events, color: Colors.white, size: 20);
      default:
        return Text(
          '$rank',
          style: const TextStyle(
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

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber[700], size: 16);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return Icon(Icons.star_half, color: Colors.amber[700], size: 16);
        } else {
          return Icon(Icons.star_border, color: Colors.amber[700], size: 16);
        }
      }),
    );
  }

  void _showContactDialog(BuildContext context, String volunteerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact $volunteerName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contact options:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Send Email'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement email functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Send Message'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement messaging functionality
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVolunteerApplicationForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Become a Volunteer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join our community of food rescue heroes!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'As a volunteer, you\'ll help deliver surplus food to those who need it most. '
                  'Fill out this form to get started on your volunteer journey.',
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Why do you want to volunteer?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Submit Application'),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement volunteer application submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}