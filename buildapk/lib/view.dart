import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pdascantree.dart';
import 'outputlist.dart';

class View extends StatelessWidget {
  final int userId;
  final String tokenLogin;
  final int compStoreId;
  final String code;
  final String customer;
  final String purpose;

  const View(
      {super.key,
      required this.userId,
      required this.tokenLogin,
      required this.compStoreId,
      required this.code,
      required this.customer,
      required this.purpose});

  final String url = "http://125.253.121.180/CommonService.svc/";
  final String ticketByIdUrl = "Store/GetCompStoreById?id=";
  final String storeListByIdUrl = "StoreList/GetStoreListByCompStoreId?id=";

  Future<dynamic> ticketById() async {
    try {
      var result = await http.get(Uri.parse(url +
          ticketByIdUrl +
          compStoreId.toString() +
          "&token=" +
          tokenLogin));
      return json.decode(result.body)['store_info'];
    } catch (Exc) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchStoreLists() async {
    var result = await http.get(Uri.parse(url +
        storeListByIdUrl +
        compStoreId.toString() +
        "&token=" +
        tokenLogin));
    List<dynamic> lst = json.decode(result.body)['store_info'];
    return lst;
  }

  String _product(dynamic storeList) {
    return storeList['product'] +
        ' - ' +
        storeList['tree'].toString() +
        ' CÂY/ ' +
        storeList['quantity'].toString();
  }

  String _data(dynamic storeList) {
    String result = storeList['color'] +
        ' - ' +
        (storeList['unit'] == null ? '' : storeList['unit']) +
        ' - ' +
        storeList['sizecode'] +
        ' - ' +
        storeList['price'].toString() +
        ' - ' +
        storeList['total'].toString();
    return result;
  }

  int _id(dynamic storeList) {
    return storeList['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OutputList(userId: userId, tokenLogin: tokenLogin)))),
          toolbarHeight: 130,
          title: Text(
              "CHI TIẾT PHIẾU XUẤT:\n" +
                  "Mã:" +
                  code +
                  "\nKhách:" +
                  customer +
                  "\nMục đích:" +
                  purpose,
              style: TextStyle(fontFamily: 'times', color: Colors.white)),
          actions: <Widget>[
            GestureDetector(
              onTap: () {},
              child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      icon: Icon(Icons.document_scanner_outlined,
                          color: Colors.blue),
                      label: Text("Quét",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PDAScanBarcode(
                                      userId: userId,
                                      tokenLogin: tokenLogin,
                                      compStoreId: compStoreId,
                                      compStoreCode: code,
                                      compStoreCustomer: customer,
                                      compStorePurpose: purpose,
                                      fromForm: 3,
                                    )));
                      })),
            ),
          ]),
      body: FutureBuilder<List<dynamic>>(
        future: fetchStoreLists(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          _product(snapshot.data[index]),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'times'),
                        ),
                        subtitle: Text(
                          _data(snapshot.data[index]),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'times'),
                        ),
                      ),
                    ],
                  ));
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
