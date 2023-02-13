import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'outputlist.dart';

class PDAScanBarcode2Return extends StatefulWidget {
  final int userId;
  final String tokenLogin;

  const PDAScanBarcode2Return({
    super.key,
    required this.userId,
    required this.tokenLogin,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PDAScanBarcode2Return> {
  static const MethodChannel methodChannel =
      MethodChannel('baotin.pda.qrcode/scan');
  static const EventChannel eventChannel =
      EventChannel('baotin.pda.qrcode/get');

  //String _scanStatus = 'Không thể đọc QRCode.';
  String _qrCode = '';
  String _result = '';
  int _id = 0;

  final String url = "http://125.253.121.180/CommonService.svc/";
  final String removeUrl = "Tree/Remove?id=";

  Future<String> scanTree(int id, bool isRemove) async {
    if (id <= 0) return 'Cây không hợp lệ.';
    var result;

    result = await http.delete(
        Uri.parse(url +
            removeUrl +
            id.toString() +
            "&compStoreId=0&token=" +
            tokenLogin),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    String res = result.body;
    if (res == '\"0\"') {
      return 'Cây hợp lệ để trả hàng.';
    } else
      return 'Cây không hợp lệ.';
  }

  int userId = 0;
  String tokenLogin = '';
  int compStoreId = 0;
  String compStoreCode = '';
  String compStoreCustomer = '';
  String compStorePurpose = '';

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    tokenLogin = widget.tokenLogin;
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
        _timer = new Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            if (_id > 0)
              scanTree(_id, isRemove).then((String result) {
                setState(() {
                  _result = result;
                  _id = 0;
                });
              });
          });
        });
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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Trả Hàng',
              style: TextStyle(
                  fontFamily: 'times new roman', fontWeight: FontWeight.bold)),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                children: [
                  Divider(
                    color: Colors.blue,
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                  )
                ],
              ),
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
                      color: _result.contains('Cây hợp lệ')
                          ? Colors.blue
                          : Colors.red),
                )
              ]),
            ]));
  }
}
