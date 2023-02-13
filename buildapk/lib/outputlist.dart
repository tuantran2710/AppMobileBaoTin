import 'login.dart';
import 'pdascantree.dart';
import 'view.dart';
import 'create.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pdascantree2return.dart';

class OutputList extends StatefulWidget {
  const OutputList({super.key, required this.userId, required this.tokenLogin});

  final String tokenLogin;
  final int userId;

  @override
  _OutputListState createState() => _OutputListState();
}

class _OutputListState extends State<OutputList> {
  String tokenLogin = "";
  int userId = 0;
  final String url = "http://125.253.121.180/CommonService.svc/Store/";
  final String compstoreListUrl = "GetCompStoreAll?token=";
  final String compstoreDeleteUrl = "CompanyStore_Delete?id=";
  final String compstoreCompleteUrl = "CompanyStore_Complete?id=";

  @override
  void initState() {
    super.initState();
    tokenLogin = widget.tokenLogin;
    userId = widget.userId;
  }

  Future<List<dynamic>> fetchTickets() async {
    var result = await http.get(Uri.parse(url + compstoreListUrl + tokenLogin));
    List<dynamic> lst = json.decode(result.body)['store_info'];
    return lst;
  }

  deleteTicket(int id) async {
    var result = await http.delete(Uri.parse(
        url + compstoreDeleteUrl + id.toString() + "&token=" + tokenLogin));
  }

  completeTicket(int id) async {
    var result = await http.put(Uri.parse(
        url + compstoreCompleteUrl + id.toString() + "&token=" + tokenLogin));
  }

  String _code(dynamic companyStores) {
    return companyStores['code'];
  }

  String _customer(dynamic companyStores) {
    return companyStores['customer'];
  }

  String _purpose(dynamic companyStores) {
    return companyStores['purpose'];
  }

  String _data(dynamic companyStores) {
    return companyStores['customer'] +
        ' - ' +
        companyStores['purpose'] +
        ' - ' +
        (companyStores['batchCode'] == null ? '' : companyStores['batchCode']) +
        ' - ' +
        (companyStores['productOrder'] == null
            ? ''
            : companyStores['productOrder']) +
        ' - ' +
        companyStores['createdDate'] +
        ' - ' +
        companyStores['tree'].toString() +
        ' - ' +
        companyStores['quantity'].toString();
  }

  int _id(dynamic companyStores) {
    return companyStores['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Center(
          child: Text(
            'Danh Sách Phiếu Xuất',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'times',
            ),
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage())),
        ),
        actions: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Create(userId: userId, tokenLogin: tokenLogin)));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Icon(
                  Icons.add,
                  size: 35,
                ),
              )),
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PDAScanBarcode2Return(
                              userId: userId,
                              tokenLogin: tokenLogin,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.assignment_return, size: 30),
              ))
        ],
      ),
      body: Container(
        child: FutureBuilder<List<dynamic>>(
          future: fetchTickets(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return RefreshIndicator(
              child: _listView(snapshot),
              onRefresh: fetchTickets,
            );
          },
        ),
      ),
    );
  }

  Widget _listView(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      print(_code(snapshot.data[0]));
      return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(_code(snapshot.data[index])),
                  subtitle: Text(_data(snapshot.data[index])),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    child: Text(_id(snapshot.data[index]).toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => View(
                                  userId: userId,
                                  tokenLogin: tokenLogin,
                                  compStoreId: _id(snapshot.data[index]),
                                  code: _code(snapshot.data[index]),
                                  customer: _customer(snapshot.data[index]),
                                  purpose: _purpose(snapshot.data[index]))),
                          (route) => false);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => View(
                      //             userId: userId,
                      //             tokenLogin: tokenLogin,
                      //             compStoreId: _id(snapshot.data[index]),
                      //             code: _code(snapshot.data[index]),
                      //             customer: _customer(snapshot.data[index]),
                      //             purpose: _purpose(snapshot.data[index]))));
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 17),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            icon: Icon(
                              Icons.check,
                              color: Colors.blue,
                            ),
                            label: Text("Hoàn Tất",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        title: Text(
                                          "Hoàn Tất Phiếu Xuất",
                                        ),
                                        content: Text(
                                            "Bạn có chắc muốn hoàn tất phiếu xuất này",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        actions: <Widget>[
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                            ),
                                            icon: Icon(Icons.check,
                                                color: Colors.blue),
                                            label: Text("Có"),
                                            onPressed: () async {
                                              completeTicket(
                                                  _id(snapshot.data[index]));
                                              //fetchTickets();
                                              //Navigator.of(context).pop(true);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OutputList(
                                                              userId: userId,
                                                              tokenLogin:
                                                                  tokenLogin)));
                                            },
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                            ),
                                            icon: Icon(Icons.cancel,
                                                color: Colors.blue),
                                            label: Text('Không'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                        ]);
                                  });
                            })),
                    Padding(
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
                                            compStoreId:
                                                _id(snapshot.data[index]),
                                            compStoreCode:
                                                _code(snapshot.data[index]),
                                            compStoreCustomer:
                                                _customer(snapshot.data[index]),
                                            compStorePurpose:
                                                _purpose(snapshot.data[index]),
                                            fromForm: 1,
                                          )));
                            })),
                    Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.blue,
                            ),
                            label: Text(
                              "Xóa",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        title: Text("Xóa Dữ Liệu",
                                            style: TextStyle()),
                                        content: Text(
                                            "Bạn có chắc muốn xóa dữ liệu này",
                                            style: TextStyle()),
                                        actions: <Widget>[
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                            ),
                                            icon: Icon(Icons.check,
                                                color: Colors.blue),
                                            label: Text(
                                              "Có",
                                            ),
                                            onPressed: () async {
                                              deleteTicket(
                                                  _id(snapshot.data[index]));
                                              //Navigator.of(context).pop(false);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OutputList(
                                                              userId: userId,
                                                              tokenLogin:
                                                                  tokenLogin)));
                                            },
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                            ),
                                            icon: Icon(Icons.cancel,
                                                color: Colors.blue),
                                            label: Text(
                                              "Không",
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                        ]);
                                  });
                            })),
                  ],
                )
              ],
            ));
          });
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
