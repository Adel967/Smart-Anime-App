// import 'dart:ffi';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:direct_link/direct_link.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:netflixbro/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:device_apps/device_apps.dart';
// import 'package:android_intent/android_intent.dart';
// import 'package:open_file/open_file.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:path/path.dart';
//
//
//
// class DownloadScreen extends StatefulWidget {
//   @override
//   _DownloadScreenState createState() => _DownloadScreenState();
// }
//
// class _DownloadScreenState extends State<DownloadScreen> {
//
//   ReceivePort receivePort = ReceivePort();
//   late List<Map<String,dynamic>> files = [] ;
//   dynamic  uint8list = null ;
//   initialize()async{
//     WidgetsFlutterBinding.ensureInitialized();
//     await FlutterDownloader.initialize();
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     //initialize();
//     getFiles();
//     IsolateNameServer.registerPortWithName(receivePort.sendPort, "download");
//     receivePort.listen((message) { });
//
//
//     FlutterDownloader.registerCallback(downloadCallBack);
//     super.initState();
//   }
//
//   static downloadCallBack(String id,DownloadTaskStatus status,int progress){
//     final SendPort? sendPort = IsolateNameServer.lookupPortByName("download");
//     sendPort!.send(progress);
//   }
//
//
//
//   download(String url, String fileName) async {
//     bool isInstalled = await DeviceApps.isAppInstalled('com.dv.adm');
//     final status = await Permission.storage.request();
//     if (isInstalled && status.isGranted) {
//       final externalDir = await getExternalStorageDirectory();
//       print(externalDir!.path);
//       final AndroidIntent intent = AndroidIntent(
//         action: 'action_main',
//         package: 'com.dv.adm',
//         componentName: 'com.dv.adm.AEditor',
//         arguments: <String, dynamic>{
//           'android.intent.extra.TEXT': url,
//           'com.android.extra.filename': "$fileName.mp4",
//         },
//       );
//       await intent.launch().then((value) => null).catchError((e) => print(e));
//     } else {
//       // ask user to install the app
//     }
//   }
//
//   getFiles()async{
//     List<FileSystemEntity> _folders = [];
//       final directory = "/storage/emulated/0/ADM";
//       String pdfDirectory = '$directory/';
//       final myDir = new Directory(pdfDirectory);
//       setState(() {
//         _folders = myDir.listSync(recursive: true, followLinks: false);
//       });
//       _folders.forEach((element) async{
//         File file = File(element.path);
//         print(file.lengthSync()/ (1024 * 1024));
//         if((file.lengthSync() / (1024 * 1024)) > 20){
//           print("Hello there");
//           final uint8list = await VideoThumbnail.thumbnailData(
//               video: file.uri.path,
//               imageFormat: ImageFormat.JPEG,
//               // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
//               quality: 100,
//               timeMs: 400000
//           );
//           DateTime date = await File( element.path).lastModified();
//           setState(() {
//             files.add({
//               "file":file,
//               "thumbnail":uint8list,
//               "date":date
//             });
//           });
//
//         }
//       });
//
//
//       // print(_folders.last.uri);
//       // DateTime date = await File( _folders.last.uri.path).lastModified();
//       // print(File( _folders.last.uri.path).lengthSync());
//       // print(date.toString());
//       // await OpenFile.open(_folders.last.uri.path);
//
//
//   }
//
//   downloadFile(String url)async{
//     final status = await Permission.storage.request();
//
//     if (status.isGranted) {
//       final externalDir = await getExternalStorageDirectory();
//       print(externalDir);
//       final id = await FlutterDownloader.enqueue(
//         url:
//         url,
//         savedDir: externalDir!.path,
//         fileName: "download2.mp4",
//         showNotification: true,
//         openFileFromNotification: true,
//       );
//
//
//     } else {
//       print("Permission deined");
//     }
//   }
//
//   directLink(String url)async{
//     print("..");
//     final check = await DirectLink.check(url);
//
//     if (check == null) {
//       // null condition
//       print("null");
//     }else{
//       check.forEach((e) {
//         print(e.quality);
//         print(e.link);
//       });
//     }
//   }
//
//   String dateFormat(DateTime date){
//     return date.year.toString() + "/" + date.month.toString() + "/" + date.day.toString() + "   " + date.hour.toString() + ":" + date.minute.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: GestureDetector(
//           //onTap: () => downloadFile("https://r3---sn-4g5ednd7.googlevideo.com/videoplayback?expire=1634088089&ei=OeBlYYLVFPyCxN8P9N6vyA0&ip=185.204.83.42&id=o-AB6TrXUROdRXdt0w9VH45Dg--SL-U2gFyAHCKO_S9XB_&itag=247&aitags=133%2C134%2C135%2C136%2C137%2C160%2C242%2C243%2C244%2C247%2C248%2C271%2C278&source=youtube&requiressl=yes&vprv=1&mime=video%2Fwebm&ns=kihyGQcwI0_pQHwj9xTjvTwG&gir=yes&clen=1991405&dur=10.720&lmt=1548475136812976&keepalive=yes&fexp=24001373,24007246&c=WEB&txp=2201222&n=M79VvJkZafX-Aw&sparams=expire%2Cei%2Cip%2Cid%2Caitags%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cns%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRAIgPIEshZgDR2DNDjC5fRXXrlapjKP1P70dEkdgkXHMA3YCIFPVwsjCk1khBJpipiToQtioZNRacmSaYOW9UJUtO5KA&alr=yes&cpn=hyn_dzfgmb3Lwb08&cver=2.20211009.11.00&cm2rm=sn-nx5cvox-5uie7s,sn-hgnld7s&redirect_counter=2&cms_redirect=yes&mh=Uc&mm=34&mn=sn-4g5ednd7&ms=ltu&mt=1634066448&mv=m&mvi=3&pl=22&lsparams=mh,mm,mn,ms,mv,mvi,pl&lsig=AG3C_xAwRAIgP9dmDhhROLIR39UVdBTgw81z0dAM5VvckYvU1YU3MNsCICVX4b1XAdCgG1vfYbwD1M5h-VvQnmh_vL_hJ8ffTfra&rn=34"),
//           //onTap: () => directLink("https://ok.ru/videoembed/947875089023"),
//           // onTap: () async{
//           //   print("....");
//           //   await Services.getDirectLink();
//           // },
//           //onTap: () => getFiles(),
//           //onTap: () => download("https://ok6-6.vkuser.net/?expires=1634560285008&srcIp=185.217.173.8&srcAg=CHROME_ANDROID&ms=95.142.206.133&type=2&sig=80WynUpN4zE&ct=0&urls=45.136.21.13%3B185.226.53.37&clientType=0&zs=43&id=1705514306247&/الحلقة : 220.mp4", "anime"),
//           child: SafeArea(
//             child: files.isEmpty ? CircularProgressIndicator(color: Colors.red,) : ListView.builder(
//               itemCount: files.length,
//               padding: EdgeInsets.all(10),
//               itemBuilder: (context,index){
//                 Map<String,dynamic> map = files[index];
//                 return GestureDetector(
//                   // onTap: () async{
//                   //   await OpenFile.open(map["file"].path);
//                   // },
//                   onTap: () async{
//                     print("....");
//                     await Services.getDirectLink();
//                   },
//                   child: Container(
//                     margin: EdgeInsets.symmetric(vertical: 10),
//                     height: 80,
//                     child: Row(
//                       children: [
//                         Image.memory(map["thumbnail"],height: 80,width: 120,fit: BoxFit.cover,),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       basename(map["file"].path.toString().replaceAll(".mp4", "")),
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.w600
//                                       ),
//                                     ),
//                                     SizedBox(height: 8,),
//                                     Text(
//                                       dateFormat(map["date"]),
//                                       style: TextStyle(
//                                           color: Colors.grey[350],
//                                           fontSize: 14,
//
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   (map["file"].lengthSync()/ (1024 * 1024)).round().toString() + " mb",
//                                   style: TextStyle(
//                                     color: Colors.grey[350],
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             )
//           )
//         ),
//       ),
//     );
//   }
// }
