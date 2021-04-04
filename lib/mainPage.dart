import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'main/favPage.dart';
import 'main/settingPage.dart';
import 'main/mapPage.dart';
import 'package:sqflite/sqflite.dart';

class MainPage extends StatefulWidget {
  final Future<Database> database;
  MainPage(this.database);
  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> with SingleTickerProviderStateMixin {
  TabController tabController;
  FirebaseDatabase _database;
  DatabaseReference reference;
  String _dataURL =
      'https://flutter-firebase-example-5874b-default-rtdb.firebaseio.com/';

  String id;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    _database = FirebaseDatabase(databaseURL: _dataURL);
    reference = _database.reference();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    id = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: TabBarView(
        children: [
          MapPage(databaseReference: reference, db: widget.database, id: id),
          FavPage(databaseReference: reference, db: widget.database, id: id),
          SettingPage(databaseReference: reference, id: id)
        ],
        controller: tabController,
      ),
      bottomNavigationBar: TabBar(
        tabs: [
          Tab(
            text: '목록',
            icon: Icon(Icons.map),
          ),
          Tab(
            text: '즐겨찾기',
            icon: Icon(Icons.star),
          ),
          Tab(
            text: '설정',
            icon: Icon(Icons.settings),
          )
        ],
        labelColor: Colors.blue,
        indicatorColor: Colors.blueAccent,
        controller: tabController,
      ),
    );
  }
}
