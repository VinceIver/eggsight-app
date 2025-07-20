import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_scaffold.dart';

class EggLogsPage extends StatefulWidget {
  const EggLogsPage({super.key});

  @override
  State<EggLogsPage> createState() => _EggLogsPageState();
}

class _EggLogsPageState extends State<EggLogsPage> {
  String _filter = 'fresh';

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('eggs')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final docs = snapshot.data!.docs;
            final filteredDocs = _filter == 'all'
                ? docs
                : docs
                    .where((doc) =>
                        (doc['status'] ?? '').toString().toLowerCase() == _filter)
                    .toList();

            final total = docs.length;
            final fresh = docs
                .where((d) => (d['status'] ?? '').toString() == 'fresh')
                .length;
            final rotten = docs
                .where((d) => (d['status'] ?? '').toString() == 'rotten')
                .length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quality History',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown),
                ),
                const Text(
                  'Detailed inspection records and analytics',
                  style: TextStyle(color: Colors.brown),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['all', 'fresh', 'rotten'].map((type) {
                    final isSelected = _filter == type;
                    return Expanded(
                      child: Material(
                        color: isSelected ? Colors.amber : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => _filter = type),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: Text(
                              type[0].toUpperCase() + type.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.amber.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCountTile("Total Records", total, Colors.brown),
                      _buildCountTile("Fresh", fresh, Colors.green),
                      _buildCountTile("Rotten", rotten, Colors.orange),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isFresh = data['status'] == 'fresh';
                      final status = isFresh ? 'Fresh Egg' : 'Rotten Egg';
                      final batch = data['batch'] ?? 'B001';
                      final confidence = data['confidence']?.toDouble() ?? 0.0;
                      final date = (data['timestamp'] as Timestamp).toDate();
                      final timeStr = DateFormat.jm().format(date);
                      final dateStr = DateFormat.yMd().format(date);

                      return Dismissible(
                        key: Key(doc.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this log?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await FirebaseFirestore.instance
                              .collection('eggs')
                              .doc(doc.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Log deleted')),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFresh
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isFresh ? Icons.check_circle : Icons.warning,
                                    color: isFresh ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        status,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("Batch: $batch"),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${confidence.toInt()}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _getConfidenceColor(confidence),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text('$timeStr • $dateStr'),
                                  const Spacer(),
                                  Icon(Icons.trending_up,
                                      size: 16,
                                      color: _getConfidenceColor(confidence)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getConfidenceLabel(confidence),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _getConfidenceColor(confidence)),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence < 40) return Colors.red;
    if (confidence < 66) return Colors.orange;
    return Colors.green;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence < 40) return 'Low Confidence';
    if (confidence < 66) return 'Mid Confidence';
    return 'High Confidence';
  }

  Widget _buildCountTile(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            )),
      ],
    );
  }
}
