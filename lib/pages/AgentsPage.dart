import 'package:flutter/material.dart';
import 'package:flutter_application_1/helpers/DBHelper.dart';
import 'package:flutter_application_1/models/User.dart';

class AgentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agents'),
      ),
      body: FutureBuilder<List<User>>(
        future: DBHelper.instance.getAgents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final agents = snapshot.data!;
            return ListView.builder(
              itemCount: agents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(agents[index].username),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context, agents[index]); // Return the selected agent
                    },
                    child: Text('Attribuer'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
