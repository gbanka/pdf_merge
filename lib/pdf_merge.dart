import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class PdfMerge {
  static const MethodChannel _channel = const MethodChannel('pdf_merge');

  static Future<String> PdfMerger(List<String> paths) async {
    // Mapping the path to <key, value>

    final String pdfText = await _channel
        .invokeMethod('PdfMerger', <String, dynamic>{'paths': paths.join(";")});
    return pdfText;
  }

}
