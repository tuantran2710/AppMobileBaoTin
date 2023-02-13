import 'package:buildapk/caregory/debtpage.dart';
import 'package:buildapk/caregory/inventoryreport.dart';
import 'package:buildapk/caregory/storemanage.dart';
import 'package:buildapk/login.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardMenu extends StatefulWidget {
  const DashboardMenu(
      {super.key, required this.userId, required this.tokenLogin});

  final String tokenLogin;
  final int userId;
  @override
  State<DashboardMenu> createState() => _DashboardMenuState();
}

class _DashboardMenuState extends State<DashboardMenu> {
  final String url = "http://125.253.121.180/CommonService.svc/";

  late String token;
  String tokenLogin = '';
  int userId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 2,
            padding: EdgeInsets.all(7),
            tabs: [
              GButton(
                icon: Icons.assignment_outlined,
                text: "Quản Lý Kho",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StoreManage(
                                
                              )));
                },
              ),
              GButton(
                icon: Icons.attach_money_rounded,
                text: "Công Nợ",
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DebtPage()));
                },
              ),
              GButton(
                icon: Icons.search,
                text: 'Tra Cứu',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.help_outline,
                text: "Trợ Giúp",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                height: 430,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      image: AssetImage('images/baotincontainer7.jpg'),
                      fit: BoxFit.cover),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          " Tổng Quan",
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              const UserAccountsDrawerHeader(
                accountName: Text(
                  "BẢO TÍN",
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                accountEmail: Text("baotinsoftware@gmail.com",
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.red,
                  backgroundImage: NetworkImage(
                      'https://znews-photo.zingcdn.me/w1920/Uploaded/bzwvopcg/2020_12_09/lee.jpeg'),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg'),
                      fit: BoxFit.cover),
                ),
              ),
              Column(
                children: [
                  Divider(
                    color: Colors.black,
                    height: 20,
                    indent: 4,
                    endIndent: 4,
                    thickness: 1,
                  )
                ],
              ),
              ListTile(
                leading:
                    Icon(Icons.notifications, color: Colors.black, size: 25),
                title: const Text("Thông Báo",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.category_outlined,
                    color: Colors.black, size: 25),
                title: const Text("Danh Mục",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.assignment_outlined,
                    color: Colors.black, size: 25),
                title: const Text("Quản Lý Kho",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreManage(
                          
                        ),
                      ));
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_chart_outlined_outlined,
                    color: Colors.black, size: 25),
                title: const Text("Thông Kê",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.attach_money_rounded,
                    color: Colors.black, size: 25),
                title: const Text("Công Nợ",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DebtPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle_outlined,
                    color: Colors.black, size: 25),
                title: const Text("Người Dùng",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading:
                    Icon(Icons.help_outline, color: Colors.black, size: 25),
                title: const Text("Trợ Giúp",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading:
                    Icon(Icons.vpn_key_outlined, color: Colors.black, size: 25),
                title: const Text("Đổi Mật Khẩu",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading:
                    Icon(Icons.logout_outlined, color: Colors.black, size: 25),
                title: const Text("Đăng Xuất",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
              Column(
                children: [
                  Divider(
                    color: Colors.black,
                    height: 20,
                    indent: 4,
                    endIndent: 4,
                    thickness: 1,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                " © 2021-2023. Toàn bộ bản quyền thuộc Bảo Tín Software & Automation 4.0+",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Helvetica',
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
