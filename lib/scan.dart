import 'dart:async';
import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Settings.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      reassemble();
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.resumeCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Route _createRoute(page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        elevation: 0,
        title: Text('Code Scanner'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: (() {
              Navigator.of(context).push(_createRoute(Settings()));
            }),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                      overlayColor: Color.fromARGB(166, 0, 0, 0)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: InkWell(
                      onTap: (() async {
                        await controller!.toggleFlash();
                      }),
                      child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(8, 8, 8, 0.541)),
                          child: Center(
                            child: Icon(
                              Icons.flash_on_rounded,
                              color: Colors.white,
                            ),
                          )),
                    )),
                    SizedBox(
                      height: 30,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    bool dialogopened = false;
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      print(result);
      bool isLink = false;
      result = scanData;
      if (result!.code.toString().contains('http')) {
        isLink = true;
      }

      if (!dialogopened)
        showDialog(
            context: context,
            builder: (context) {
              dialogopened = true;
              return Dialog(
                child: Container(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(scanData.code.toString()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                dialogopened = false;
                                Navigator.pop(context);
                              },
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 15,
                                  width: isLink
                                      ? MediaQuery.of(context).size.width / 4
                                      : MediaQuery.of(context).size.width / 1.5,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(child: Text('Back'))),
                            ),
                            if (isLink)
                              InkWell(
                                onTap: (() {
                                  launchlinks(context, scanData.code.toString(),
                                      scanData.code.toString());
                                }),
                                child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 15,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    decoration: BoxDecoration(
                                        color: Colors.cyan,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(child: Text('Open'))),
                              ),
                          ],
                        )
                      ]),
                ),
              );
            });

      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

launchlinks(context, IosLink, AndriodLink) async {
  if (Platform.isIOS) {
    if (await canLaunchUrl(IosLink)) {
      await launchUrl(IosLink);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text('Unable to connect with the app')));
    }
  } else {
    if (await canLaunchUrl(AndriodLink)) {
      await launchUrl(AndriodLink);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text('Unable to connect with the app')));
    }
  }
}
