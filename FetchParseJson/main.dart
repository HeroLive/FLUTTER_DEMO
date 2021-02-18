import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Geo {
  final String lat;
  final String lng;

  Geo({this.lat, this.lng});

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(lat: json['lat'], lng: json['lng']);
  }
}

class Address {
  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;
  Address({this.street, this.suite, this.city, this.zipcode, this.geo});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      suite: json['suite'],
      city: json['city'],
      zipcode: json['zipcode'],
      geo: Geo.fromJson(json['geo']),
    );
  }
}

class Company {
  final String name;
  final String catchPhrase;
  final String ps;

  Company({this.name, this.ps, this.catchPhrase});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      catchPhrase: json['catchPhrase'],
      ps: json['ps'],
    );
  }
}

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final Address address;
  final String phone;
  final String website;
  final Company company;

  User(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.address,
      this.phone,
      this.website,
      this.company});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        username: json['username'],
        email: json['email'],
        address: Address.fromJson(json['address']),
        phone: json['phone'],
        website: json['website'],
        company: Company.fromJson(json['company']));
  }
}

List<User> parseUsers(String resBody) {
  final parsed = jsonDecode(resBody).cast<Map<String, dynamic>>();
  return parsed.map<User>((json) => User.fromJson(json)).toList();
}

Future<List<User>> fetchUsers(http.Client client) async {
  final response =
      await client.get('https://jsonplaceholder.typicode.com/users');
  return parseUsers(response.body);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Parse Json';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: FutureBuilder<List<User>>(
          future: fetchUsers(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? UserName(users: snapshot.data)
                : Center(child: CircularProgressIndicator());
          },
        ));
  }
}

class UserName extends StatelessWidget {
  final List<User> users;
  UserName({this.users});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.cyan[200],
          margin: EdgeInsets.all(10.0),
          child: Column(
            children: [
              ListTile(
                title: Text('${users[index].name}',
                    style: Theme.of(context).textTheme.headline5),
                subtitle: Text('${users[index].company.name}',
                    style: Theme.of(context).textTheme.subtitle2),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.email,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text('${users[index].email}',
                      style: Theme.of(context).textTheme.button),
                ],
              ),
              Divider(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.place_outlined,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                      '${users[index].address.suite}, ${users[index].address.street}, ${users[index].address.city}',
                      style: Theme.of(context).textTheme.button),
                ],
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('${users[index].phone}',
                    style: Theme.of(context).textTheme.button),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                dense: true,
              ),
              ListTile(
                leading: Icon(Icons.web),
                title: Text('${users[index].website}',
                    style: Theme.of(context).textTheme.button),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                dense: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
