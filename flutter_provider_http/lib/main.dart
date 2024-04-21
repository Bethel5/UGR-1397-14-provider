import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSONPlaceholder Users',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: UserListScreen(),
      ),
    );
  }
}

class User {
  final int userId;
  final int id;
  final String name;
  final String email;

  User({required this.userId, required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class UserProvider extends ChangeNotifier {
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.https('jsonplaceholder.typicode.com', 'users'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _users = data.map((json) => User.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load users');
    }
  }
}

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: Center(
        child: userProvider.users.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: userProvider.users.length,
                itemBuilder: (context, index) {
                  User user = userProvider.users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => userProvider.fetchUsers(),
        tooltip: 'Fetch Users',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
