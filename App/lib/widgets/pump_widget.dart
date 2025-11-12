import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/notifications_helper.dart';

class PumpWidget extends StatefulWidget {
  const PumpWidget({super.key});

  @override
  State<PumpWidget> createState() => _PumpWidgetState();
}

class _PumpWidgetState extends State<PumpWidget> {
  final DatabaseReference _pumpRef = FirebaseDatabase.instance.ref('switch/state');
  final DatabaseReference _pumpOffRef = FirebaseDatabase.instance.ref('switch/lastOffTime');
  final DatabaseReference _pumpOnRef = FirebaseDatabase.instance.ref('switch/lastOnTime');
  // final DatabaseReference _lastSyncRef = FirebaseDatabase.instance.ref('status/lastSync');

  String pumpState = "Loading...";
  String lastOff = "Loading...";
  String lastOn = "Loading...";
  String lastSync = "Loading...";
  String? _lastPumpState;

  @override
  void initState() {
    super.initState();
    _listenPumpState();
    _listenTimestamps();
  }
  String formatTimestamp(dynamic value) {
    if (value == null) return "N/A";

    try {
      // Convert to DateTime
      DateTime dt;
      if (value is int) {
        // If your Firebase stores timestamp as milliseconds since epoch
        dt = DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        // If Firebase stores ISO string like "2025-11-12 17:13:53"
        dt = DateTime.parse(value.toString());
      }

      // Format like: Mon 3 July 2025 @ 7:15 PM
      return DateFormat("EEE d MMM''yy '@' h:mm a").format(dt);
    } catch (e) {
      return value.toString(); // fallback
    }
  }


  void _listenPumpState() {
    _pumpRef.onValue.listen((event) {
      final data = event.snapshot.value;
      final newState = data == true ? "ON" : "OFF";

      if (_lastPumpState != newState) {
        setState(() => pumpState = newState);
        addMessage("Pump state changed: $pumpState");
        showLocalNotification("Pump State Changed", "Pump is now $pumpState");
        _lastPumpState = newState;
      } else {
        setState(() => pumpState = newState);
      }
    });
  }

  void _listenTimestamps() {
    _pumpOffRef.onValue.listen((e) {
      setState(() => lastOff = formatTimestamp(e.snapshot.value));
    });
    _pumpOnRef.onValue.listen((e) {
      setState(() => lastOn = formatTimestamp(e.snapshot.value));
    });
    // _lastSyncRef.onValue.listen((e) {
    //   setState(() => lastSync = formatTimestamp(e.snapshot.value));
    // });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Pump State",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        SizedBox(
          width: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                pumpState == "ON" ? Icons.waves : FontAwesomeIcons.dropletSlash,
                size: 40,
                color: pumpState == "ON" ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              Text(
                pumpState,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: pumpState == "ON" ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            SizedBox(height: 8),
            Text("Last Pump Off: $lastOff"),
            SizedBox(height: 6),
            Text("Last Pump On: $lastOn"),
            // Text("Last ESP Heartbeat Time: $lastSync"),
          ],
        ),
      ],
    );
  }
}

