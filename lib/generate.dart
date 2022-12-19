import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class GenerateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String? _inputErrorText;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Generator'),
        backgroundColor: Colors.cyan,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              _saveqrtogallery();
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: (() {
              _saveandshare();
            }),
          )
        ],
      ),
      body: _contentWidget(),
    );
  }

  Future<void> _saveqrtogallery() async {
    var dcimPath = await AndroidPathProvider.dcimPath;
    final myImagePath = '${dcimPath}/CodeScanner';
    try {
      await Directory(myImagePath).create();
      print('done');
    } catch (e) {}
    try {
      RenderRepaintBoundary? boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary!.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final datetime = DateTime.now();

      final file = await File('${myImagePath}/${datetime}.png').create();
      file.writeAsBytesSync(pngBytes);
      Fluttertoast.showToast(msg: 'Saved QR');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _saveandshare() async {
    var dcimPath = await AndroidPathProvider.dcimPath;
    final myImagePath = '${dcimPath}/CodeScanner';
    try {
      await Directory(myImagePath).create();
      print('done');
    } catch (e) {}
    try {
      RenderRepaintBoundary? boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary!.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final datetime = DateTime.now();

      final file = await File('${myImagePath}/${datetime}.png').create();
      file.writeAsBytesSync(pngBytes);

      await FlutterShare.shareFile(
        title: 'QR Code',
        text: 'Code Scanner',
        filePath: '${myImagePath}/${datetime}.png',
      );
    } catch (e) {
      print(e.toString());
    }
  }

  bool _iscontentempty = true;

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _iscontentempty
                  ? Text('Type a message')
                  : Center(
                      child: RepaintBoundary(
                        key: globalKey,
                        child: QrImage(
                          data: _dataString,
                          size: 0.5 * bodyHeight,
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child: Container(
              height: _topSectionHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        if (value == '') {
                          setState(() {
                            _iscontentempty = true;
                          });
                        }
                      },
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Enter a custom message",
                        errorText: _inputErrorText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FlatButton(
                      child: Text("SUBMIT"),
                      onPressed: () {
                        setState(() {
                          _dataString = _textController.text;
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_dataString != '') {
                            _iscontentempty = false;
                          }
                          _inputErrorText = null;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
