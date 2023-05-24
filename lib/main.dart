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
      "http://167.99.186.175:3000/api/v1/business/businessInfor/upload_data/";

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
      dio.options.headers["Authorization"] = "Token $token";
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
  bool isLoading = false;
  String text = 'select File';
  String businessRegisterStatus = "reg";
  String modeStatus = "dark";
  List<int> imageData = [];
  TextEditingController controller = TextEditingController();

  Dio dio = new Dio();

  List<Map<String, dynamic>> businessStatus = [
    {
      'value': "reg",
      "lable": "Register",
    },
    {
      'value': "regS",
      "lable": "Register Selected",
    },
    {
      'value': "unreg",
      "lable": "unregister",
    },
    {
      'value': "unregS",
      "lable": "unregister Selected",
    },
  ];
  List<Map<String, dynamic>> businessmode = [
    {
      'value': "dark",
      "lable": "dark Mode",
    },
    {
      'value': "light",
      "lable": "light Mode",
    },
  ];

  String url = "http://167.99.186.175:3000/api/v1/business/marker/";

  String token = "c295f898d13b594b034f41a3ca1c66d7b3326baa";

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
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: businessRegisterStatus,
              elevation: 16,
              onChanged: (String? value) {
                setState(() {
                  businessRegisterStatus = value!;
                });
              },
              items: businessStatus
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                return DropdownMenuItem<String>(
                  value: value['value'],
                  child: Text(value['lable']),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 30,
            ),
            DropdownButton<String>(
              value: modeStatus,
              elevation: 16,
              onChanged: (String? value) {
                setState(() {
                  modeStatus = value!;
                });
              },
              items: businessmode
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                return DropdownMenuItem<String>(
                  value: value['value'],
                  child: Text(value['lable']),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Marker Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            OutlinedButton.icon(
              onPressed: imagePickerAction,
              icon: const Icon(Icons.upload),
              label: const Text("Select Image"),
            ),
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
                onPressed: controller.text.isEmpty && imageData.isEmpty
                    ? null
                    : postData,
                child: const Text("Upload Marker"))
          ],
        ),
      ),
    );
  }
}
