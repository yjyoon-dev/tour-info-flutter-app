import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:tour_info_flutter_app/data/tour.dart';
import 'package:tour_info_flutter_app/data/listData.dart';
import 'package:sqflite/sqflite.dart';

class MapPage extends StatefulWidget {
  final DatabaseReference databaseReference;
  final Future<Database> db;
  final String id;

  MapPage({this.databaseReference, this.db, this.id});
  @override
  State<StatefulWidget> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  List<DropdownMenuItem> list = List();
  List<DropdownMenuItem> subList = List();
  List<TourData> tourData = List();
  ScrollController _scrollController;

  String authKey =
      '95NE%2FyrFsX%2B4evKhO86ZvEug2V%2Bx1hy%2BDVWThu0Y%2BW80Nktg%2FioiAULFeZr43Ma96lnLLaKZUOW0r%2Bd2%2FLI1Kg%3D%3D';

  Item area;
  Item kind;
  int page = 1;

  void initState() {
    super.initState();
    list = Area().seoulArea;
    subList = Kind().kinds;

    area = list[0].value;
    kind = subList[0].value;

    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        page++;
        getAreaList(area: area.value, contentTypeId: kind.value, page: page);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('검색하기')),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  DropdownButton(
                    items: list,
                    onChanged: (value) {
                      Item selectedItem = value;
                      setState(() {
                        area = selectedItem;
                      });
                    },
                    value: area,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
                    items: subList,
                    onChanged: (value) {
                      Item selectedItem = value;
                      setState(() {
                        kind = selectedItem;
                      });
                    },
                    value: kind,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    onPressed: () {
                      page = 1;
                      tourData.clear();
                      getAreaList(
                          area: area.value,
                          contentTypeId: kind.value,
                          page: page);
                    },
                    child: Text(
                      '검색하기',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blueAccent,
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        child: Row(
                          children: [
                            Hero(
                              tag: 'tourinfo$index',
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: tourData[index].imagePath !=
                                                  null
                                              ? NetworkImage(
                                                  tourData[index].imagePath)
                                              : AssetImage(
                                                  'repo/images/map_location.png')))),
                            ),
                            SizedBox(width: 20),
                            Container(
                              child: Column(
                                children: [
                                  Text(
                                    tourData[index].title,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('주소 : ${tourData[index].address}'),
                                  tourData[index].tel != null
                                      ? Text('전화번호 : ${tourData[index].tel}')
                                      : Container(),
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              ),
                              width: MediaQuery.of(context).size.width - 150,
                            )
                          ],
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                  itemCount: tourData.length,
                  controller: _scrollController,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  void getAreaList({int area, int contentTypeId, int page}) async {
    var url = 'http://api.visitkorea.or.kr/openapi/service/rest/KorService/'
        'areaBasedList?serviceKey=$authKey&pageNo=$page&MobileApp=TourInfoFlutterApp'
        '&MobileOS=AND&areaCode=1&sigunguCode=$area&listYN=Y&_type=json';
    if (contentTypeId != 0) url += '&contentTypeId=$contentTypeId';
    var response = await http.get(url);
    String body = utf8.decode(response.bodyBytes);
    print(body);
    var json = jsonDecode(body);
    if (json['response']['header']['resultCode'] == "0000") {
      if (json['response']['body']['items'] == '') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('마지막 데이터입니다.'),
          ),
        );
      } else {
        List jsonArray = json['response']['body']['items']['item'];
        for (var s in jsonArray) {
          setState(() {
            tourData.add(TourData.fromJson(s));
          });
        }
      }
    } else
      print('error');
  }
}
