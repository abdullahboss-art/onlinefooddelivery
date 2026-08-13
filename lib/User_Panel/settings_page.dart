import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      body: Column(
        children: [

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            onChanged: (val) {
              setState(() {
                darkMode = val;
              });
            },
          ),

          ListTile(
            title: const Text("Privacy Policy"),
            onTap: () {},
          ),

          ListTile(
            title: const Text("Change Password"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}