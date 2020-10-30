import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const bookURL="https://stephenadamsdesign.com/EpubDescription_6574839201hgjfFKGITN_/assets/atlas.epub";


void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  Dio dio = new Dio();

  @override
  void initState() {
    super.initState();
//    download();
  }

  download() async {
    if (Platform.isIOS) {
      print('download');
      await downloadFile();
    } else {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Epub Reader'),
            backgroundColor: const Color(0xFF00226B)
        ),
        body: Center(
          child: loading
              ? CircularProgressIndicator()
              : FlatButton(
            onPressed: () async {
              Directory appDocDir =
              await getApplicationDocumentsDirectory();
              print('$appDocDir');

              String iosBookPath = '${appDocDir.path}/book.epub';
              print(iosBookPath);
//            String androidBookPath = 'file:///android_asset/book.epub';
              EpubViewer.setConfig(
                  themeColor: Theme.of(context).primaryColor,
                  identifier: "iosBook",
                  scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                  allowSharing: false,
                  enableTts: true,
                  nightMode: false);
//                    EpubViewer.open(
//                      Platform.isAndroid ? androidBookPath : iosBookPath,
//                      lastLocation: EpubLocator.fromJson({
//                        "bookId": "2239",
//                        "href": "/OEBPS/ch06.xhtml",
//                        "created": 1539934158390,
//                        "locations": {
//                          "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
//                        }
//                      }),
//                    );

              await EpubViewer.openAsset(
                'assets/book.epub',
                lastLocation: EpubLocator.fromJson({
                  "bookId": "2239",
                  "href": "/OEBPS/ch06.xhtml",
                  "created": 1539934158390,
                  "locations": {
                    "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                  }
                }),
              );
              // get current locator
              EpubViewer.locatorStream.listen((locator) {
                print(
                    'LOCATOR: ${EpubLocator.fromJson(jsonDecode(locator))}');
              });
            },
            child: Container(
              child: Text('Read Book'),
            ),
          ),
        ),
      ),
    );
  }

  Future downloadFile() async {
    print('download1');
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      await startDownload();
    } else {
      await startDownload();
    }
  }

  startDownload() async {
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir.path + '/book.epub';
    File file = File(path);
//    await file.delete();

    if (!File(path).existsSync()) {
      await file.create();
      await dio.download(
        '$bookURL',
        path,
        deleteOnError: true,
        onReceiveProgress: (receivedBytes, totalBytes) {
          print((receivedBytes / totalBytes * 100).toStringAsFixed(0));
          //Check if download is complete and close the alert dialog
          if (receivedBytes == totalBytes) {
            loading = false;
            setState(() {});
          }
        },
      );
    } else {
      loading = false;
      setState(() {});
    }
  }
}
