import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
// import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        home: CustomFilePicker() //set the class here
    );
  }
}

class CustomFilePicker extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _CustomFilePicker();
  }
}

class _CustomFilePicker extends State<CustomFilePicker>{

  FilePickerResult selectedfile;
  Response response;
  String progress;
  Dio dio = new Dio(new BaseOptions(
    baseUrl: "http://140.118.115.149:8908/send_pic.php",
    connectTimeout: 5000,
    receiveTimeout: 1000,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json

  ));



  selectFile() async {
    selectedfile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'mp4'],
    );
    setState((){}); //update the UI so that file name is shown
  }

  uploadFile() async {
    String uploadurl = "http://140.118.115.149:8908/send_pic.php";
    Map<String ,dynamic> map = Map();
    map["file"] = await MultipartFile.fromFile(selectedfile.paths[0],filename: basename(selectedfile.paths[0]));

    ///通过FormData

    FormData formData = FormData.fromMap(map);

    ///发送post

    response = await dio.post(uploadurl, data: formData,
        onSendProgress: (int sent, int total) {
          String percentage = (sent/total*100).toStringAsFixed(2);
          setState(() {

            progress = "$sent" + " Bytes of " "$total Bytes - " +  percentage + " % uploaded";
            //update the progress

          });
        },);

    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP
      if(response.statusCode == 200){
        print(response.data);
        // print(response.headers);
        //print response from server
      }else{
        // print(response.statusCode);
        print("Error during connection to server.");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:Text("Select File and Upload"),
          backgroundColor: Colors.orangeAccent,
        ), //set appbar
        body:Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(40),
            child:Column(children: <Widget>[

              Container(
                margin: EdgeInsets.all(10),
                //show file name here
                child:progress == null?
                Text("Progress: 0%"):
                Text(basename("Progress: $progress"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),),
                //show progress status here
              ),

              Container(
                margin: EdgeInsets.all(10),
                //show file name here
                child:selectedfile == null?
                Text("Choose File"):
                Text(basename(selectedfile.paths[0])),
                //basename is from path package, to get filename from path
                //check if file is selected, if yes then show file name
              ),

              Container(
                  child:ElevatedButton.icon(
                    onPressed: (){
                      selectFile();
                    },
                    icon: Icon(Icons.folder_open),
                    label: Text("CHOOSE FILE"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shadowColor: Colors.brown,
                    )
                    // color: Colors.redAccent,
                    // colorBrightness: Brightness.dark,
                  )
              ),

              //if selectedfile is null then show empty container
              //if file is selected then show upload button
                selectedfile == null?
                Container():
                Container(
                  child: ElevatedButton.icon(
                    onPressed: (){
                      uploadFile();
                    },
                    icon: Icon(Icons.folder_open),
                    label: Text("UPLOAD FILE"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shadowColor: Colors.brown,
                    ),
                  ),
                )
            ],)
        )
    );
  }
}