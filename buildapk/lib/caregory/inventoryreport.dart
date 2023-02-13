import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InventoryReport extends StatefulWidget {
  const InventoryReport(
      {super.key, required this.userId, required this.tokenLogin});

  final String tokenLogin;
  final int userId;

  @override
  _InventoryReportState createState() => _InventoryReportState();
}

class _InventoryReportState extends State<InventoryReport> {
  String tokenLogin = "";
  int userId = 0;
  final String url = "http://125.253.121.180/CommonService.svc/Remain";
  final String remainListUrl = "GetRemains?storeSubId=1&storeId=5&token=";

  @override
  void initState() {
    super.initState();
    tokenLogin = widget.tokenLogin;
    userId = widget.userId;
  }

  Future<List<dynamic>> fetchTickets() async {
    var result = await http.get(Uri.parse(url + remainListUrl + tokenLogin));
    List<dynamic> lst = json.decode(result.body)['remain_info'];
    return lst;
  }

  String _KgRemain(dynamic remainStores) {
    return remainStores['KgRemain'];
  }

  String _Product(dynamic remainStores) {
    return remainStores['Product'];
  }

  String _StoreSubCode(dynamic remainStores) {
    return remainStores['StoreSubCode'];
  }

  String _data(dynamic remainStores) {
    return remainStores['Product'] +
        ' - ' +
        remainStores['ProductId'] +
        ' - ' +
        remainStores['TreeRemain'];
  }

  int _id(dynamic companyStores) {
    return companyStores['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Báo Cáo Hàng Tồn",
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
      ),
      // body: Container(
      //   child: FutureBuilder<List<dynamic>>(
      //     future: fetchTickets(),
      //     builder: (BuildContext context, AsyncSnapshot snapshot) {
      //       return RefreshIndicator(
      //         child: _listView(snapshot),
      //         onRefresh: fetchTickets,
      //       );
      //     },
      //   ),
      // ),
    );
  }

  // Widget _listView(AsyncSnapshot snapshot) {
  //   if (snapshot.hasData) {
  //     print(_KgRemain(snapshot.data[0]));
  //     return ListView.builder(
  //         padding: EdgeInsets.all(8),
  //         itemCount: snapshot.data.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           return Card(
  //             child: Column(
  //               children: <Widget>[
  //                 ListTile(
  //                     title: Text(_KgRemain(snapshot.data[index])),
  //                     subtitle: Text(_data(snapshot.data[index])),
  //                     trailing: ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         primary: Colors.white,
  //                       ),
  //                       child: Text(_id(snapshot.data[index]).toString()),
  //                       onPressed: (() {}),
  //                     ))
  //               ],
  //             ),
  //           );
  //         });
  //   }
  // }
}
