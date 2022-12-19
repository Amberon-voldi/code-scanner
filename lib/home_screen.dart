import 'package:code_scanner/generate.dart';
import 'package:code_scanner/scan.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int i = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> pages = <Widget>[ScanScreen(), GenerateScreen()];

  void changeindex(int index) {
    if (i == 0) {
      setState(() {
        i = 1;
      });
    } else if (i == 1) {
      setState(() {
        i = 0;
      });
    }
    print('index changed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          elevation: 5,
          type: BottomNavigationBarType.fixed,
          currentIndex: i,
          selectedItemColor: Colors.cyan,
          onTap: changeindex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code), label: 'Generator')
          ]),
      body: Center(child: pages.elementAt(i)),
    );
  }
}
