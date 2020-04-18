import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gia_vang/Model/GoldModel.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Cập Nhật Giá Vàng'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StreamController<List<GoldModel>> goldStream =
      StreamController<List<GoldModel>>();

  @override
  void initState() {
    super.initState();
    getDataGold();
  }

  @override
  void dispose() {
    super.dispose();
    goldStream.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<GoldModel>>(
        stream: goldStream.stream,
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final goldData = asyncSnapshot.data;
          return ListView.separated(
            itemCount: goldData.length,
            itemBuilder: (context, index) =>
                _builderGoldInfoRowData(goldData[index], index),
            separatorBuilder: (BuildContext context, int index) => Container(
              height: 2,
              color: const Color(0xffCC9900),
            ),
          );
        },
      ),
    );
  }

  Future<void> getDataGold() async {
    final goldData = <GoldModel>[];

    const url = "http://sjc.com.vn/giavang/textContent.php";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final listTr = document.querySelectorAll("tr");
      for (final trItem in listTr) {
        try {
          final listTd = trItem.querySelectorAll("td");
          final gold = GoldModel(
            name: listTd[0].text,
            oldPrice: listTd[1].text,
            newPrice: listTd[2].text,
          );
          goldData.add(gold);
        } catch (e) {
          //print(e.message);
        }
      }
    } else {
      //print("Request failed with status code: ${response.statusCode}");
    }
    goldStream.sink.add(goldData);
  }

  Widget _builderGoldInfoRowData(goldModel, index) {
    return Container(
      color: Color(0xff1a237e),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                goldModel.name,
                textAlign: index == 0 ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 50,
              color: index == 0 ? Colors.transparent : Colors.blue,
              child: Center(
                child: Text(
                  goldModel.oldPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: index == 0 ? Colors.yellow : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 50,
              color: index == 0 ? Colors.transparent : Colors.blue,
              child: Center(
                child: Text(
                  goldModel.newPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: index == 0 ? Colors.yellow : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
