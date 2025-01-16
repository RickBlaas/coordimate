import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../constants/storage_keys.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logger = Logger();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await storage.read(key: 'jwt');
    logger.d('HomePage - Stored token: $token');
  }

  @override
  Widget build(BuildContext context) {
    // Check desktop screen fo the appbar
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        title: const Text('Homepagina', style: TextStyle(
          color: Colors.white,
        )),
        backgroundColor: Colors.blue[400],
        centerTitle: true,   
      ),

      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              ),
              const Text('Maak een team aan!'),
              const SizedBox(height: 300),
              FilledButton(
                onPressed: () {
                  context.go('/myteams');
                }, 
                child: const Text('Ga naar teams')
              ) 
            ],
          )
        ],
      ),
    );
  }
}