import 'pdascantree.dart';
import 'outputlist.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Create extends StatelessWidget {
  final int userId;
  final String tokenLogin;

  Create({super.key, required this.userId, required this.tokenLogin});

  final String url = "http://125.253.121.180/CommonService.svc/";
  final String purposeListUrl = "Purpose/GetListPurpose?token=";
  final String customerListUrl =
      "Customer/GetListCustomerByActorTypeId?actorTypeId=2&token=";
  final String createTicketUlr = "Store/CompanyStore_Insert";
  final String ticketByIdUrl = "Store/GetCompStoreById?id=";

  List<dynamic> lstPurposes = <String>[];
  List<dynamic> lstCustomers = <String>[];
  String code = "";
  String customer = "";
  String purpose = "";

  Future<List<String>> fetchPurposes() async {
    var result = await http.get(Uri.parse(url + purposeListUrl + tokenLogin));
    lstPurposes = json.decode(result.body)['purposes'];
    List<String> lstResult = <String>[];
    for (int i = 0; i < lstPurposes.length; i++) {
      lstResult.add(lstPurposes[i]["id"].toString() +
          '-' +
          lstPurposes[i]["name"].toString());
    }

    return lstResult;
  }

  int _purposeId(String purpose) {
    return int.parse(purpose.substring(0, purpose.indexOf("-")));
  }

  Future<List<String>> fetchCustomers() async {
    var result = await http.get(Uri.parse(url + customerListUrl + tokenLogin));
    lstCustomers = json.decode(result.body)['customers'];
    List<String> lstResult = <String>[];
    for (int i = 0; i < lstCustomers.length; i++) {
      lstResult.add(lstCustomers[i]["id"].toString() +
          '-' +
          lstCustomers[i]["name"].toString());
    }

    return lstResult;
  }

  int _customerId(String customer) {
    return int.parse(customer.substring(0, customer.indexOf("-")));
    // int result = 0;
    // for(int i=0;i<lstCustomers.length;i++) {
    //   if(lstCustomers[i]["name"].toString()==customer) {
    //     result = lstCustomers[i]["id"];
    //     break;
    //   }
    // }
    // return result;
  }

  Future<int> createTicket(int purposeId, int customerId) async {
    var result = await http.post(Uri.parse(url + createTicketUlr),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'UserId': userId,
          'CustomerId': customerId,
          'PurposeId': purposeId,
          'StoreId': 5,
          'StoreSubId': 1,
          'Token': tokenLogin
        }));
    dynamic item = json.decode(result.body)['store_info'];
    code = item['code'].toString();
    customer = item['customer'].toString();
    purpose = item['purpose'].toString();
    return int.parse(item['id'].toString());
  }

  final dropPurposes = GlobalKey<DropdownSearchState<String>>();
  final dropCustomers = GlobalKey<DropdownSearchState<String>>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text("Tạo Phiếu Xuất",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'times')),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OutputList(userId: userId, tokenLogin: tokenLogin))),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return Container(
              alignment: Alignment.center,
              child: Form(
                  key: _formKey,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        DropdownSearch<String>(
                          key: dropPurposes,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                          ),
                          asyncItems: (dynamic filter) => fetchPurposes(),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Mục Đích",
                              labelStyle: TextStyle(
                                  fontFamily: 'times new roman',
                                  fontWeight: FontWeight.bold),
                              hintText: "Chọn mục đích",
                              hintStyle: TextStyle(
                                  fontFamily: 'times new roman',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onChanged: (String? data) => print(data),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Chưa chọn mục đích";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        DropdownSearch<String>(
                          key: dropCustomers,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                          ),
                          asyncItems: (dynamic filter) => fetchCustomers(),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                                labelText: "Khách Hàng",
                                labelStyle: TextStyle(
                                    fontFamily: 'times new roman',
                                    fontWeight: FontWeight.bold),
                                hintText: "Chọn khách hàng",
                                hintStyle: TextStyle(
                                    fontFamily: 'times new roman',
                                    fontWeight: FontWeight.bold)),
                          ),
                          onChanged: print,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Chưa chọn khách hàng';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                            primary: Colors.white,
                          ),
                          icon: Icon(
                            Icons.create,
                            color: Colors.blue,
                          ),
                          label: Text("Tạo Phiếu",
                              style: TextStyle(
                                  fontFamily: 'times',
                                  fontWeight: FontWeight.bold)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              int purposeId = _purposeId(dropPurposes
                                  .currentState?.getSelectedItem as String);
                              int customerId = _customerId(dropCustomers
                                  .currentState?.getSelectedItem as String);
                              createTicket(purposeId, customerId)
                                  .then((int compStoreId) {
                                if (compStoreId > 0)
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
                                                fromForm: 2,
                                              )));
                              });
                            }
                          },
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                            primary: Colors.white,
                          ),
                          icon: Icon(Icons.arrow_back, color: Colors.blue),
                          label: Text("Quay lại",
                              style: TextStyle(
                                  fontFamily: 'times',
                                  fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      ])));
        }));
  }
}
