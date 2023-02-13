import 'dart:convert';
import 'dart:async';
import 'package:buildapk/dashboardmenu.dart';

import 'outputlist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  final String url = "http://125.253.121.180/SecurityService.svc/Security/";
  final String tokenUrl =
      "GetToken?publicKey=BAOTINPUBLICKEY_123456789&secretKey=BAOTINSECRETKEY_123456789";
  final String loginUrl = "Login?";
  late String token;
  late int userId;

  Future<String> login(String userName, String password) async {
    var result = await http.get(Uri.parse(url + tokenUrl));
    String getToken = json.decode(result.body)['accesstoken'];
    if (getToken.length > 0) {
      result = await http.get(Uri.parse(url +
          loginUrl +
          "userName=" +
          userName +
          "&password=" +
          password +
          "&token=" +
          getToken));
      dynamic obj = json.decode(result.body);
      if (obj['islogin_success'] == 'false')
        return "";
      else {
        token = obj['token_loginsuccess'];
        userId = obj["id"];

        return token;
      }
    } else
      return "";
  }

  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Image.asset('images/baotin2.png'),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 500,
                  width: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: AssetImage('images/baotincontainer6.jpg'),
                        fit: BoxFit.cover),
                  ),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 1,
                          ),
                          // Icon(
                          //   Icons.key,
                          //   size: 50,
                          //   color: Colors.blue,
                          // ),
                          SizedBox(
                            height: 240,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  controller: txtUsername,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nhập tài khoản đăng nhập đúng.';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Tài khoản',
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Helvetica',
                                      ))),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Helvetica',
                                ),
                                controller: txtPassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nhập mật khẩu đúng.';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Mật khẩu',
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Helvetica',
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 1,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 110),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue[300],
                                  ),
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  label: Text("Đăng nhập",
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.white,
                                      )),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      login(txtUsername.text, txtPassword.text)
                                          .then((String result) {
                                        if (result.length > 0) {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             OutputList(
                                          //                 userId: userId,
                                          //                 tokenLogin: token)));
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DashboardMenu(
                                                        tokenLogin: token,
                                                        userId: userId,
                                                      )));
                                        }
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 20),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Column(
                          //         children: [
                          //           Container(
                          //             width: 180,
                          //             height: 180,
                          //             child: Row(children: [
                          //               // Image.asset('images/sp1.png')
                          //             ]),
                          //           ),
                          //         ],
                          //       ),
                          //       Padding(
                          //         padding: const EdgeInsets.only(bottom: 70),
                          //         child: Container(
                          //           width: 180,
                          //           height: 180,
                          //           child: Row(children: [
                          //             // Image.asset('images/sp2.png'),
                          //           ]),
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                        ],
                      )),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "CTCP PHẦN MỀM & CÔNG NGHỆ TỰ ĐỘNG 4.0 BẢO TÍN\n📱HOTLINE: 0817.789.789 - 0787.797.797\n📩EMAIL:INFO@BAOTINSOFTWARE.VN\n🌎WEBSITE:BAOTINSOFTWARE.VN",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Helvetica',
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
