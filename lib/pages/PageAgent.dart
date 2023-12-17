import 'package:flutter/material.dart';

class AgentPage extends StatelessWidget {
  const AgentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Page'),
      ),
      body: const Center(
        child: Text('This is the Agent Page'),
      ),
    );
  }
}
