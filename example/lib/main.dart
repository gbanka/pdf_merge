import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_merge/pdf_merge.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _isLoadPermission = false;
  int _inProgress = 0;
  String _pdfText = '_pdfText';
  Timer _timeLoop;

  @override
  void initState() {
    super.initState();
  }

  void getPermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        _isLoadPermission = false;
      });
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      getPermission();
    }
  }

  mainPage() {
    return """
    <!doctype html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <meta name="description" content="">
      <meta name="author" content="">
      <style>
      ${getCss()}
      </style>
      </head>
      <body>
        <main role="main">
      
        <!-- Main jumbotron for a primary marketing message or call to action -->
        <div class="jumbotron">
          <div class="container">
            <h1 class="display-3">Hello, world!</h1>
            <p>This is a template for a simple marketing or informational website. It includes a large callout called a jumbotron and three supporting pieces of content. Use it as a starting point to create something more unique.</p>
            <p><a class="btn btn-primary btn-lg" href="#" role="button">Learn more &raquo;</a></p>
          </div>
        </div>
        
        </main>
    """;
  }

  startHtml() {
    return """
    <!doctype html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <meta name="description" content="">
      <meta name="author" content="">
      <style>
      ${getCss()}
      </style>
      </head>
      <body>
        <table class="table">
    """;
  }

  rowHtml(int index) {
    return """
    <tr>
      <td>${index}</td>
      <td>Test</td>
      <td>x2</td>
      <td>x3</td>
      <td>x4</td>
      <td>Test 2</td>
      <td>x6</td>
      <td>x7</td>
      <td>Test 3</td>
      <td>x9</td>
      <td>x10</td>
    </tr>
    """;
  }

  endHtml() {
    return """
        </table>
      </body>
</html>
""";
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  getPath() async {
    String fileName = getRandomString(10) + '.html';

    final output = await getExternalStorageDirectory();

    String path = "${output.path}/" + fileName;
    return path;
  }

  Future<String> generateHtml(int number) async {
    String path = await getPath();
    File newHtml = File(path);
    // await newHtml.writeAsString("test tekstu", mode: FileMode.writeOnlyAppend);

    await newHtml.writeAsString(startHtml(), mode: FileMode.writeOnlyAppend);

    if (number == 0) {
      await newHtml.writeAsString(mainPage(), mode: FileMode.writeOnlyAppend);
    } else {
      for (int i = 0; i < 100; i++) {
        await newHtml.writeAsString(rowHtml(i), mode: FileMode.writeOnlyAppend);
      }
    }

    await newHtml.writeAsString(endHtml(), mode: FileMode.writeOnlyAppend);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    var targetPath = appDocDir.path;

    DateTime now = new DateTime.now();
    var targetFileName =
        (now.millisecondsSinceEpoch).toString() + "_" + number.toString();

    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlFile(
        newHtml, targetPath, targetFileName);

    String generatedPdfFilePath = generatedPdfFile.path;
    // debugPrint("generatedPdfFilePath=" + generatedPdfFilePath);

    return generatedPdfFilePath;
  }

  bodyLoadPermission() {
    return Column(
      children: [
        Text('Checking storage permission'),
        CircularProgressIndicator()
      ],
    );
  }

  bodyLoaded() {
    switch (_inProgress) {
      case 0:
        return Column(
          children: [
            Text('Permission checked'),
            RaisedButton(
              child: Text("Create pdf and merge them"),
              onPressed: () {
                setState(() {
                  _inProgress = 1;
                });

                createFiles();
              },
            )
          ],
        );
        break;

      case 1:
        return Column(
          children: [
            Text('In Progress'),
            Text('Merge 10 file to one PDF'),
            CircularProgressIndicator(),
            RaisedButton(
              child: Text("Restart"),
              onPressed: () {
                setState(() {
                  _inProgress = 1;
                });

                // createFiles();
              },
            )
          ],
        );
        break;
    }
  }

  Future<String> PdfMerger(List<String> paths) async {
    String text = "";
    try {
      text = await PdfMerge.PdfMerger(paths);
    } on PlatformException {
      text = 'Failed to get PDF text.';
    }
    return text;
  }

  createFiles() async {
    List<String> paths = [];

    for (int i = 0; i < 10; i++) {
      await generateHtml(i).then((value) {
        _pdfText = _pdfText + "\n" + "[Created] " + value;
        paths.add(value);
      });
    }

    PdfMerger(paths).then((text) {
      setState(() {
        _inProgress = 0;
        _pdfText = _pdfText + "\n" + "[Merger to] " + text;
        OpenFile.open(text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getPermission();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Merge example'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: _isLoadPermission ? bodyLoadPermission() : bodyLoaded()),
            Expanded(
                child: Container(
                    color: Colors.green,
                    child: SingleChildScrollView(child: Text(_pdfText)))),
          ],
        ),
      ),
    );
  }

  getCss() {
    return """
    
""";
  }
}
