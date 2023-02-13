import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'outputlist.dart';
import 'view.dart';

class PDAScanBarcode extends StatefulWidget {
  final int userId;
  final String tokenLogin;
  final int compStoreId;
  final String compStoreCode;
  final String compStoreCustomer;
  final String compStorePurpose;

  final int fromForm;

  const PDAScanBarcode(
      {super.key,
      required this.userId,
      required this.tokenLogin,
      required this.compStoreId,
      required this.compStoreCode,
      required this.compStoreCustomer,
      required this.compStorePurpose,
      required this.fromForm});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PDAScanBarcode> {
  static const MethodChannel methodChannel =
      MethodChannel('baotin.pda.qrcode/scan');
  static const EventChannel eventChannel =
      EventChannel('baotin.pda.qrcode/get');

  //String _scanStatus = 'Không thể đọc QRCode.';
  String _qrCode = '';
  String _result = '';
  int _id = 0;

  final String url = "http://125.253.121.180/CommonService.svc/";
  final String scanUrl = "Tree/Scan?id=";
  final String storeListByIdUrl = "StoreList/GetStoreListByCompStoreId?id=";

  String _addedTrees = '';
  Future<String> scanTree(int id) async {
    if (id <= 0) return 'Cây không hợp lệ.';
    var result = await http.post(
        Uri.parse(url +
            scanUrl +
            id.toString() +
            "&compStoreId=" +
            compStoreId.toString() +
            "&userId=" +
            userId.toString() +
            "&token=" +
            tokenLogin),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    String res = result.body;
    int pos = res.indexOf(' -');
    try {
      int num = int.parse(res.substring(1, pos));
      if (num > 0) {
        _addedTrees += id.toString() + ', ';
        return 'Cây hợp lệ. Thông tin cây:\r\n' + res;
      } else
        return 'Cây không hợp lệ.';
    } catch (Exception) {
      return 'Cây không hợp lệ.';
    }
  }

  String _detail = '';
  Future<String> fetchStoreLists() async {
    var result = await http.get(Uri.parse(url +
        storeListByIdUrl +
        compStoreId.toString() +
        "&token=" +
        tokenLogin));
    List<dynamic> lst = json.decode(result.body)['store_info'];
    String detail = '';
    for (int i = 0; i < lst.length; i++) {
      detail += lst[i]['product'] +
          ' - ' +
          lst[i]['color'] +
          ' - ' +
          lst[i]['tree'].toString() +
          ' Cây' +
          ' - ' +
          lst[i]['quantity'].toString() +
          ' MÉT' +
          ' - ' +
          lst[i]['sizecode'] +
          '\r\n';
    }
    return detail;
  }

  int userId = 0;
  String tokenLogin = '';
  int compStoreId = 0;
  String compStoreCode = '';
  String compStoreCustomer = '';
  String compStorePurpose = '';

  int fromForm = 0;
  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    userId = widget.userId;
    tokenLogin = widget.tokenLogin;
    compStoreId = widget.compStoreId;
    compStoreCode = widget.compStoreCode;
    compStoreCustomer = widget.compStoreCustomer;
    compStorePurpose = widget.compStorePurpose;
    fromForm = widget.fromForm;
    fetchStoreLists().then((String result) {
      setState(() {
        _detail = result;
      });
    });
    // _timer = new Timer(const Duration(milliseconds: 1000), () {
    //   setState(() {
    //     if (_id>0)
    //       scanTree(_id).then((String result) {
    //       setState(() {
    //         _result = result;
    //         _id = 0;
    //         fetchStoreLists().then((String result) {
    //           setState(() {
    //             _detail = result;
    //           });
    //         });
    //       });
    //     });
    //   });
    // });
  }

  bool isRemove = false;
  late Timer _timer;
  void _onEvent(Object? event) {
    setState(() {
      _qrCode = "${event}";
      int pos = _qrCode.indexOf('\r\n');
      String tmp;
      if (pos > -1)
        tmp = _qrCode.substring(0, _qrCode.indexOf('\r\n'));
      else
        tmp = _qrCode;
      tmp = tmp.substring(tmp.indexOf(':') + 1);
      try {
        _id = int.parse(tmp);
        if (_addedTrees.contains(_id.toString())) {
          _result = 'Cây này đã xuất.';
          _timer.cancel();
        } else {
          _timer = new Timer(const Duration(milliseconds: 1000), () {
            setState(() {
              if (_id > 0)
                scanTree(_id).then((String result) {
                  setState(() {
                    _result = result;
                    _id = 0;
                    fetchStoreLists().then((String result) {
                      setState(() {
                        _detail = result;
                      });
                    });
                  });
                });
            });
          });
        }
      } catch (Exception) {
        _result = 'Mã này không đúng định dạng.';
        _timer.cancel();
      }
    });
  }

  void _onError(Object error) {
    setState(() {
      _qrCode = 'Không thể đọc QRCode.';
    });
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Quét QRCode Sản Phẩm',
              style: TextStyle(
                  fontFamily: 'times new roman', fontWeight: FontWeight.bold)),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              switch (fromForm) {
                case 1:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OutputList(
                              userId: userId, tokenLogin: tokenLogin)));
                  break;
                case 2:
                  Navigator.pop(context, true);
                  break;
                case 3:
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => View(
                              userId: userId,
                              tokenLogin: tokenLogin,
                              compStoreId: compStoreId,
                              code: compStoreCode,
                              customer: compStoreCustomer,
                              purpose: compStorePurpose)),
                      (route) => false);
                  break;
              }
            },
          ),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                  //ROW 1
                  children: [
                    Text('TỔNG QUAN PHIẾU:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'times',
                            color: Colors.blue,
                            fontSize: 20)),
                  ]),
              Row(children: [
                Text(
                    'MÃ PHIẾU:' +
                        compStoreCode +
                        '\n' +
                        'KHÁCH HÀNG:' +
                        compStoreCustomer +
                        '\n' +
                        'MỤC ĐÍCH:' +
                        compStorePurpose,
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'times new roman',
                        color: Colors.black))
              ]),
              // Row(children: [
              // Column(children: <Widget>[
              //   FutureBuilder<List<dynamic>>(
              //     future: fetchStoreLists(),
              //     builder: (BuildContext context, AsyncSnapshot snapshot) {
              //       if (snapshot.hasData) {
              //         return ListView.builder(
              //             padding: EdgeInsets.all(8),
              //             itemCount: snapshot.data.length,
              //             itemBuilder: (BuildContext context, int index) {
              //               return Card(
              //                   child: Column(
              //                     children: <Widget>[
              //                       ListTile(
              //                         title: Text(
              //                           _product(snapshot.data[index]),
              //                           style: TextStyle(
              //                               fontSize: 20, fontWeight: FontWeight.bold),
              //                         ),
              //                         subtitle: Text(
              //                           _data(snapshot.data[index]),
              //                           style: TextStyle(
              //                               fontSize: 15, fontWeight: FontWeight.bold),
              //                         ),
              //                       ),
              //                     ],
              //                   ));
              //             });
              //       } else {
              //         return Center(child: CircularProgressIndicator());
              //       }
              //     },
              //   ),
              // ])]
              // ),
              Column(
                children: [
                  Divider(
                    color: Colors.black,
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                  )
                ],
              ),
              Row(
                  //ROW 2
                  children: [
                    Text('CHI TIẾT PHIẾU:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'times new roman',
                            color: Colors.blue)),
                  ]),

              Row(
                children: [
                  Text(
                    _detail,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'times new roman',
                        color: Colors.black),
                  ),
                ],
              ),
              Column(
                children: [
                  Divider(
                    color: Colors.black,
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                  )
                ],
              ),

              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.black,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: isRemove,
                    onChanged: (bool? value) {
                      setState(() {
                        isRemove = value!;
                      });
                    },
                  ),
                  Text("Loại cây vừa quét khỏi phiếu",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'times new roman',
                          color: Colors.black)),
                ],
              ),
              // Row(
              //     //ROW 2
              //     children: [
              //       Text('CÁC CÂY ĐÃ XUẤT:',
              //           style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 18,
              //               fontFamily: 'times new roman',
              //               color: Colors.blue)),
              //     ]),
              // Row(
              //     //ROW 2
              //     children: [
              //       Text(_addedTrees,
              //           style: TextStyle(
              //               fontSize: 15,
              //               fontFamily: 'times new roman',
              //               color: Colors.black,)),
              //     ]),

              // Row(children: [
              //   Text('QRCODE:',
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         fontSize: 18,
              //         fontFamily: 'times new roman',
              //         color: Colors.blue,
              //       )),
              // ]),
              // Row(
              //     //ROW 2
              //     children: [
              //       Text(_qrCode,
              //           style: TextStyle(
              //               fontSize: 18,
              //               fontFamily: 'times new roman',
              //               color: Colors.yellow))
              //     ]),

              Row(children: [
                Text(
                  'KẾT QUẢ:\n',
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'times new roman',
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                )
              ]),
              Row(children: [
                Text(
                  '$_result',
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'times new roman',
                      color: _result.contains('Cây hợp lệ.')
                          ? Colors.blue
                          : Colors.red),
                )
              ]),
            ]));
  }
}
