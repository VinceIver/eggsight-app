import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_scaffold.dart';

class EggTrendsPage extends StatelessWidget {
  const EggTrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Visual Analytics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Comprehensive data visualization and trends',
            style: TextStyle(color: Colors.brown),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('eggs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              }
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final docs = snapshot.data!.docs;
              final now = DateTime.now();
              final last7Dates =
                  List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

              //  dates to yyyy-MM-dd string keys for safety
              String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

              final freshPerDay = {for (var d in last7Dates) formatDate(d): 0};
              final rottenPerDay = {for (var d in last7Dates) formatDate(d): 0};
              int freshTotal = 0;
              int rottenTotal = 0;

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp).toDate();
                final status = data['status'];
                final dayKey = formatDate(timestamp);

                if (freshPerDay.containsKey(dayKey)) {
                  if (status == 'fresh') {
                    freshPerDay[dayKey] = freshPerDay[dayKey]! + 1;
                    freshTotal++;
                  } else if (status == 'rotten') {
                    rottenPerDay[dayKey] = rottenPerDay[dayKey]! + 1;
                    rottenTotal++;
                  }
                }
              }

              final total = (freshTotal + rottenTotal).toDouble();

              return Column(
                children: [
                  _buildCard(
                    icon: Icons.pie_chart,
                    iconColor: Colors.orange.shade100,
                    title: 'Quality Distribution',
                    subtitle: 'Fresh vs Rotten Breakdown',
                    content: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            height: 280,
                            width: 280,
                            child: PieChart(
                              PieChartData(
                                centerSpaceRadius: 0,
                                sectionsSpace: 2,
                                sections: [
                                  PieChartSectionData(
                                    value: freshTotal.toDouble(),
                                    color: Colors.green,
                                    title: total == 0
                                        ? '0%'
                                        : '${((freshTotal / total) * 100).toStringAsFixed(0)}%',
                                    titleStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    radius: 100,
                                  ),
                                  PieChartSectionData(
                                    value: rottenTotal.toDouble(),
                                    color: Colors.orange,
                                    title: total == 0
                                        ? '0%'
                                        : '${((rottenTotal / total) * 100).toStringAsFixed(0)}%',
                                    titleStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    radius: 100,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegend(color: Colors.green, label: 'Fresh'),
                            const SizedBox(width: 20),
                            _buildLegend(color: Colors.orange, label: 'Rotten'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChart(
                    title: 'Daily Rotten Detection',
                    subtitle: 'Weekly trend analysis',
                    icon: Icons.bolt,
                    iconColor: Colors.amber.shade100,
                    color: Colors.orange,
                    dataPoints: rottenPerDay,
                    last7Dates: last7Dates,
                    formatDate: formatDate,
                  ),
                  const SizedBox(height: 16),
                  _buildChart(
                    title: 'Daily Fresh Detection',
                    subtitle: 'Weekly trend analysis',
                    icon: Icons.eco,
                    iconColor: Colors.green.shade100,
                    color: Colors.green,
                    dataPoints: freshPerDay,
                    last7Dates: last7Dates,
                    formatDate: formatDate,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor,
                child: Icon(icon, color: Colors.orange),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildChart({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color color,
    required Map<String, int> dataPoints,
    required List<DateTime> last7Dates,
    required String Function(DateTime) formatDate,
  }) {
    final maxY = _calculateMaxY(dataPoints.values);
    final interval = _calculateInterval(maxY);

    return _buildCard(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      content: Container(
        padding: const EdgeInsets.only(right: 8),
        height: 220,
        color: color.withOpacity(0.05),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: interval,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index >= 0 && index < last7Dates.length) {
                      final date = last7Dates[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          DateFormat('E').format(date), // Mon, Tue...
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  last7Dates.length,
                  (i) {
                    final key = formatDate(last7Dates[i]);
                    return FlSpot(i.toDouble(), dataPoints[key]!.toDouble());
                  },
                ),
                isCurved: true,
                curveSmoothness: 0.3,  
                color: color,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(Iterable<int> values) {
    if (values.isEmpty) return 10;
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    // Add 20% padding on top, min 10
    return (max * 1.2).clamp(10, double.infinity);
  }

  double _calculateInterval(double maxY) {
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    return 20;
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
