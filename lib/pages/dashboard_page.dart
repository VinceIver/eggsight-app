import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_scaffold.dart';

class EggDashboard extends StatelessWidget {
  const EggDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference eggs = FirebaseFirestore.instance.collection('eggs');

    return CustomScaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: eggs.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // All-time counts (no filtering)
          final allFreshEggs = docs
              .where((doc) => (doc['status'] ?? '').toString().toLowerCase() == 'fresh')
              .length;
          final allRottenEggs = docs
              .where((doc) => (doc['status'] ?? '').toString().toLowerCase() == 'rotten')
              .length;
          final allTotalEggs = docs.length;

          // Today's date string for filtering recent activity only
          final now = DateTime.now();
          final todayDateString = DateFormat('yyyy-MM-dd').format(now);

          // Filter docs for today only
          final todayDocs = docs.where((doc) {
            final Timestamp ts = doc['timestamp'] as Timestamp;
            final DateTime date = ts.toDate();
            final dateString = DateFormat('yyyy-MM-dd').format(date);
            return dateString == todayDateString;
          }).toList();

          final todayFreshEggs = todayDocs
              .where((doc) => (doc['status'] ?? '').toString().toLowerCase() == 'fresh')
              .length;
          final todayRottenEggs = todayDocs
              .where((doc) => (doc['status'] ?? '').toString().toLowerCase() == 'rotten')
              .length;
          final todayTotalEggs = todayDocs.length;

          final lastSorted = todayDocs.isNotEmpty
              ? (todayDocs.first['timestamp'] as Timestamp).toDate()
              : null;
          final formattedTime = lastSorted != null
              ? TimeOfDay.fromDateTime(lastSorted).format(context)
              : 'N/A';

          final mostCommon = todayFreshEggs >= todayRottenEggs ? 'Fresh' : 'Rotten';

          return ListView(
            children: [
              _buildTopHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildStatCard(
                      icon: Icons.center_focus_strong,
                      label: "Total Inspected",
                      value: allTotalEggs,
                      subtitle: "All time",
                      color: Colors.orange,
                      trend: "+15%",
                      trendColor: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      icon: Icons.egg,
                      label: "Fresh Eggs",
                      value: allFreshEggs,
                      subtitle: "All time",
                      color: Colors.green,
                      trend: "+12%",
                      trendColor: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      icon: Icons.flash_on,
                      label: "Rotten Eggs",
                      value: allRottenEggs,
                      subtitle: "All time",
                      color: Colors.orange,
                      trend: "-8%",
                      trendColor: Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    _buildStatCard(
                      icon: Icons.history,
                      label: "Recent Activity",
                      value: todayTotalEggs,
                      subtitle: "Last: $formattedTime • Most: $mostCommon",
                      color: Colors.amber,
                      trend: "Today",
                      trendColor: Colors.black87,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    final date = DateTime.now();
    final formattedDate = DateFormat('M/d/yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Egg Quality Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required String subtitle,
    required Color color,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                trend,
                style: TextStyle(
                  color: trendColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                trend.contains('-') ? Icons.trending_down : Icons.trending_up,
                size: 16,
                color: trendColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
