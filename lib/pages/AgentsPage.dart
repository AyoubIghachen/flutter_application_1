import 'package:flutter/material.dart';

class AgentsPage extends StatelessWidget {
  final List<String> agents = [
    'Agent 1',
    'Agent 2',
    'Agent 3'
  ]; // Replace with your list of agents

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agents'),
      ),
      body: ListView.builder(
        itemCount: agents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(agents[index]),
            trailing: ElevatedButton(
              onPressed: () {
                // Handle the Attribuer button press
              },
              child: Text('Attribuer'),
            ),
          );
        },
      ),
    );
  }
}
