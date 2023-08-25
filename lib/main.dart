import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Yshuf",
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: Text("Chatter application"),
              bottom: const TabBar(tabs: [
                Tab(
                  text: "Upload Business",
                ),
                Tab(
                  text: "Upload Marker",
                ),
              ])),
          body: const TabBarView(
            children: [BusinessUpload(), MarkerUpload()],
          ),
        ),
      ),
    );
  }
}

class BusinessUpload extends StatefulWidget {
  const BusinessUpload({super.key});

  @override
  State<BusinessUpload> createState() => _BusinessUploadState();
}

class _BusinessUploadState extends State<BusinessUpload> {
  bool isLoading = false;
  String text = 'select File';

  Dio dio = new Dio();

  String url =
      "http://mediaupload.joinchatter.ca/api/v1/business/businessInfor/upload_data/";

  String token = "c295f898d13b594b034f41a3ca1c66d7b3326baa";

  void fileUploadAction() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result!.files.single.path!.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
            result.files.single.path.toString(),
            filename: "data.csv"),
      });
      dio.options.headers["Content-Type"] = "multipart/form-data";

      Response response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        setState(() {
          text = "File upload Success";
          isLoading = false;
        });
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            text = "select File";
            isLoading = false;
          });
        });
      } else {
        setState(() {
          text = "File upload Failure";
          isLoading = false;
        });
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            text = "select File";
            isLoading = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: isLoading,
        child: Center(
          child: ElevatedButton(
            onPressed: fileUploadAction,
            child: Text(text),
          ),
        ));
  }
}

class MarkerUpload extends StatefulWidget {
  const MarkerUpload({super.key});

  @override
  State<MarkerUpload> createState() => _MarkerUploadState();
}

class _MarkerUploadState extends State<MarkerUpload> {
  String text = 'select File';
  List<int> imageData = [];

  void imagePickerAction() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );
    File file = File(result!.files.single.path.toString());
    imageData = file.readAsBytesSync();
    setState(() {});
  }

  void postData() async {
    String data = base64.encode(imageData);
    Clipboard.setData(ClipboardData(text: data));
    imageData = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: imagePickerAction,
              icon: const Icon(Icons.upload),
              label: const Text("Select Image"),
            ),
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
                onPressed: imageData.isEmpty ? null : postData,
                child: const Text("Copy Marker Date"))
          ],
        ),
      ),
    );
  }
}
