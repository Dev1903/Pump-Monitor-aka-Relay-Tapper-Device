import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/notifications_helper.dart';

class PumpWidget extends StatefulWidget {
  const PumpWidget({super.key});

  @override
  State<PumpWidget> createState() => _PumpWidgetState();
}

class _PumpWidgetState extends State<PumpWidget> {
  final DatabaseReference _pumpRef =
  FirebaseDatabase.instance.ref('switch/state');
  final DatabaseReference _pumpOffRef =
  FirebaseDatabase.instance.ref('switch/lastOffTime');
  final DatabaseReference _pumpOnRef =
  FirebaseDatabase.instance.ref('switch/lastOnTime');

  String pumpState = "Loading...";
  String lastOff = "Loading...";
  String lastOn = "Loading...";
  String? _lastPumpState;

  @override
  void initState() {
    super.initState();

    // Wait for anonymous authentication BEFORE attaching DB listeners
    FirebaseAuth.instance.authStateChanges().listen((user) {
      print("AUTH UID = ${user?.uid}");

      if (user != null) {
        _listenPumpState();
        _listenTimestamps();
      }
    });
  }

  String formatTimestamp(dynamic value) {
    if (value == null) return "N/A";
    try{
      String s = value.toString();
      s = value.replaceAll(RegExp(r'\D'), '');

      if (s.length > 10) {
        s = s.substring(s.length - 10);
      }

      s = s.padLeft(10, '0');

      final yy = int.parse(s.substring(0, 2));
      final mm = int.parse(s.substring(2, 4));
      final dd = int.parse(s.substring(4, 6));
      final hh = int.parse(s.substring(6, 8));
      final min = int.parse(s.substring(8, 10));

      if (mm < 1 || mm > 12 || dd < 1 || dd > 31 || hh > 23 || min > 59) {
        return "Invalid date";
      }

      final dt = DateTime(2000 + yy, mm, dd, hh, min);

      // ✅ Your desired output format
      return DateFormat("EEE d MMM''yy '@' h:mm a").format(dt);
    }
    catch(_){
      return value.toString();
  }

  }

  void _listenPumpState() {
    _pumpRef.onValue.listen(
          (event) {
        print("STATE DATA: ${event.snapshot.value}");

        final data = event.snapshot.value;
        final newState = data == true ? "ON" : "OFF";

        if (_lastPumpState != newState) {
          setState(() => pumpState = newState);

          addMessage("Pump state changed: $pumpState");
          showLocalNotification(
            "Pump State Changed",
            "Pump is now $pumpState",
          );

          _lastPumpState = newState;
        } else {
          setState(() => pumpState = newState);
        }
      },
      onError: (e) {
        print("DB ERROR (state): $e");
      },
    );
  }

  void _listenTimestamps() {
    _pumpOffRef.onValue.listen(
          (event) {
        setState(() => lastOff = formatTimestamp(event.snapshot.value));
      },
      onError: (e) {
        print("DB ERROR (lastOff): $e");
      },
    );

    _pumpOnRef.onValue.listen(
          (event) {
        setState(() => lastOn = formatTimestamp(event.snapshot.value));
      },
      onError: (e) {
        print("DB ERROR (lastOn): $e");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Pump State",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
        SizedBox(
          width: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                pumpState == "ON"
                    ? Icons.waves
                    : FontAwesomeIcons.dropletSlash,
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
        const SizedBox(height: 8),
        Text("Last Pump Off: $lastOff"),
        const SizedBox(height: 6),
        Text("Last Pump On: $lastOn"),
      ],
    );
  }
}
