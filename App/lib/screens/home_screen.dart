import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../widgets/pump_widget.dart';
import '../widgets/devices_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fcmToken = "Fetching...";
  bool pumpStatus = false; // Example pump status

  @override
  void initState() {
    super.initState();
    _fetchFcmToken();
  }

  Future<void> _fetchFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        setState(() {
          fcmToken = token;
        });
      } else {
        setState(() {
          fcmToken = "Failed to fetch token";
        });
      }
    } catch (e) {
      setState(() {
        fcmToken = "Error: $e";
      });
    }
  }

  void _showLogsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity, // Full width
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "App Logs",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text("FCM Token: $fcmToken"),
                    const SizedBox(height: 10),
                    Text("Pump Status: ${pumpStatus ? 'ON' : 'OFF'}"),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dev Smart Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showLogsSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            PumpWidget(),
            SizedBox(height: 30),
            DevicesWidget(),
          ],
        ),
      ),
    );
  }
}
