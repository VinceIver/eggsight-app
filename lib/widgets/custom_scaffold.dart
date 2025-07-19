import 'package:flutter/material.dart';
import '../main.dart';
import '../pages/about_page.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;

  const CustomScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: ClipPath(
          clipper: HalfCircleClipper(),
          child: Builder(
            builder: (context) => Container(
              color: Colors.amber,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color.fromARGB(0, 255, 255, 255),
                        backgroundImage: AssetImage('assets/icons/images/transparent-logo.png'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Nancy's",
                            style: const TextStyle(
                              fontFamily: 'GreatVibes',  
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              color: Colors.brown,
                            ),
                          ),
                          TextSpan(
                            text: " Fresh Eggs Atbp.",
                            style: const TextStyle(
                              
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.brown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
  backgroundColor: const Color(0xFFFFF8E7),
  child: Column(
    children: [
      DrawerHeader(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/images/banner.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/icons/images/logo.png'),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "EggSight Mobile App",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

     
      Expanded(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      ListTile(
        leading: const Icon(Icons.dashboard, color: Colors.brown),
        title: Text(
          'Home',
          style: const TextStyle(
            fontFamily: 'RobotoBold',       // Your custom font family name
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.brown,
          ),
        ),
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BottomNavApp()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.info, color: Colors.brown),
        title: Text(
          'About',
          style: const TextStyle(
            fontFamily: 'RobotoBold',      
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.brown,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AboutPage()),
          );
        },
      ),
    ],
  ),
),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    ],
  ),
),
      body: SafeArea(child: body),
    );
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2, size.height + 30,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
