import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'device_button.dart';

class DevicesWidget extends StatefulWidget {
  const DevicesWidget({super.key});

  @override
  State<DevicesWidget> createState() => _DevicesWidgetState();
}

class _DevicesWidgetState extends State<DevicesWidget> {
  bool fan = false, light = false, lamp = false;

  @override
  void initState() {
    super.initState();
    fetchDeviceStates();
  }

  Future<void> fetchDeviceStates() async {
    try {
      final res = await http.get(Uri.parse(
          'https://blr1.blynk.cloud/external/api/get?token=NiOh2gK2WEkE3Wzwp9lbECjJvPGeDNhr&V0&V1&V2'));
      final states = jsonDecode(res.body);
      setState(() {
        fan = states['V0'] == 1;
        light = states['V1'] == 1;
        lamp = states['V2'] == 1;
      });
    } catch (e) {
      debugPrint("Failed to fetch device states: $e");
    }
  }

  Future<void> toggleDevice(String device, bool currentState, Function setStateCallback) async {
    final value = currentState ? 0 : 1;
    final url =
        'https://blr1.blynk.cloud/external/api/update?token=NiOh2gK2WEkE3Wzwp9lbECjJvPGeDNhr&$device=$value';
    try {
      await http.get(Uri.parse(url));
      setStateCallback(!currentState);
    } catch (e) {
      debugPrint("Failed to toggle $device: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DeviceButton(
          label: "💡 Light",
          state: light,
          onTap: () => toggleDevice("V1", light, (v) => setState(() => light = v)),
          icon: Icons.lightbulb,
          activeColor: Colors.amber,
        ),
        DeviceButton(
          label: "🌀 Fan",
          state: fan,
          onTap: () => toggleDevice("V0", fan, (v) => setState(() => fan = v)),
          icon: FontAwesomeIcons.fan,
          activeColor: Colors.cyan,
          isFan: true,
        ),
        DeviceButton(
          label: "🛏️ Lamp",
          state: lamp,
          onTap: () => toggleDevice("V2", lamp, (v) => setState(() => lamp = v)),
          icon: Icons.bed,
          activeColor: Colors.orangeAccent,
        ),
      ],
    );
  }
}
