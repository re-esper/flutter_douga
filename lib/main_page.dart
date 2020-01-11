import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_douga/public.dart';

import 'package:flutter_douga/pages/home_page.dart';
import 'package:flutter_douga/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _tabIndex = 0;

  // 定义 tab icon
  List<Image> _tabImages = [
    Image.asset('images/tab_home.png'),
    Image.asset('images/tab_profile.png'),
  ];
  List<Image> _tabSelectedImages = [
    Image.asset('images/tab_home_selected.png'),
    Image.asset('images/tab_profile_selected.png'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: <Widget>[HomePage(), ProfilePage()],
        index: _tabIndex,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: AppColor.primary,
        border: Border(top: BorderSide.none),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _tabIcon(0),
            title: Text('首页'),
          ),
          BottomNavigationBarItem(
            icon: _tabIcon(1),
            title: Text("我的"),
          )
        ],
        currentIndex: _tabIndex,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
      ),
    );
  }

  Image _tabIcon(int index) {
    if (index == _tabIndex) {
      return _tabSelectedImages[index];
    } else {
      return _tabImages[index];
    }
  }
}
