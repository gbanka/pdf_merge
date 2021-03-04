# pdf_merge

Merge many PDF file to one.

## Usage

import 'package:pdf_merge/pdf_merge.dart';

```
  Future<String> PdfMerger(List<String> paths) async {
    String text = "";
    try {
      path = await PdfMerge.PdfMerger(paths); // Return path to merge PDF file.
    } on PlatformException {
      text = '';
    }
    return text;
  }
```
```
  @override
  Widget build(BuildContext context) {
    getPermission();

  PdfMerger(paths).then((path) {
    setState(() {
      if(path!='')
      {
        OpenFile.open(path); // https://pub.dev/packages/open_file
      }
    });
  });

})
```