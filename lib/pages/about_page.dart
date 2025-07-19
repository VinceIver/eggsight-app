import 'package:flutter/material.dart';
import '../widgets/custom_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            _buildAboutSection(
              imagePath: 'assets/icons/project_image.png',
              title: 'About the Project',
              description:
                  'The EggSight project is an IoT-based egg sorting and monitoring system. It detects fresh and rotten eggs using image classification. All data is synced to Firebase in real time. The Flutter app displays a dashboard with trends and logs. This automation aims to improve quality control and reduce waste.',
            ),
            const SizedBox(height: 36),
            _buildAboutSection(
              imagePath: 'assets/icons/client-image.jpg',
              title: 'About the Client',
              description:
                  'Nancy’s Fresh Eggs Atbp. is a small egg business in Batangas City. It delivers 30–40 trays daily to local stores and market vendors. Operated by just two people, they rely on visual inspection. Rotten eggs can cause losses and customer complaints. With EggSight, they aim to improve quality and reduce waste.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'GreatVibes', 
              fontWeight: FontWeight.w900,
              fontSize: 32,
              color: Color(0xFF5D4037), 
              shadows: [
                Shadow(
                  color: Color(0xFFFFF8E7), 
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'OpenSans', 
              fontSize: 15,
              height: 1.5,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
